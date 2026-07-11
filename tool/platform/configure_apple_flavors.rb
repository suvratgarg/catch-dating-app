#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'json'
require 'xcodeproj'

REPO_ROOT = File.expand_path('../..', __dir__)
APP_TARGETS_PATH = File.join(REPO_ROOT, 'tool', 'app_targets.json')
APP_TARGETS = JSON.parse(File.read(APP_TARGETS_PATH)).freeze
FLAVORS = APP_TARGETS.fetch('targets').to_h do |target|
  role = target.fetch('role')
  environment = target.fetch('environment')
  ios = target.fetch('ios')
  role_config = APP_TARGETS.fetch('roles').fetch(role)
  [
    ios.fetch('scheme'),
    {
      target_id: target.fetch('id'),
      flutter_target: target.fetch('entrypoint'),
      bundle_id: ios.fetch('bundleId'),
      app_name: target.fetch('displayName'),
      firebase_env: environment,
      firebase_role: role,
      firebase_role_path: role == 'host' ? 'host/' : '',
      app_icon: ios.fetch('iconSet'),
      ios_url_scheme: ios.fetch('urlScheme'),
      entitlements: role_config.fetch('iosEntitlements').sub(%r{\Aios/}, ''),
      maps_key_suffix: environment.upcase
    }.freeze
  ]
end.freeze

BUILD_MODES = {
  'Debug' => :debug,
  'Profile' => :release,
  'Release' => :release
}.freeze

def ensure_file_ref(project, group_path, file_path)
  group = project.main_group.find_subpath(group_path, true)
  ref = project.files.find { |file| file.path == file_path }
  ref || group.new_file(file_path)
end

def ensure_project_config(project, name, type, base_ref)
  config = project.build_configurations.find { |item| item.name == name }
  config ||= project.add_build_configuration(name, type)
  config.base_configuration_reference = base_ref if base_ref
  config
end

def ensure_target_config(target, name, type, base_ref, build_settings, template_name: nil)
  config = target.build_configurations.find { |item| item.name == name }
  if config.nil?
    config = target.add_build_configuration(name, type)
    if template_name
      template = target.build_configurations.find { |item| item.name == template_name }
      config.build_settings.merge!(template.build_settings) if template
    end
  end
  config.base_configuration_reference = base_ref if base_ref
  config.build_settings.merge!(build_settings)
  config
end

def write_scheme(source_scheme_path, destination_path, flavor, settings)
  xml = File.exist?(destination_path) ? File.read(destination_path) : File.read(source_scheme_path)
  BUILD_MODES.each_key do |mode|
    xml = xml.gsub(
      /buildConfiguration = "#{mode}(?:-[^"]+)?"/,
      %(buildConfiguration = "#{mode}-#{flavor}")
    )
  end
  xml = xml.gsub(/BuildableName = "[^"]+\.app"/, %(BuildableName = "#{settings[:app_name]}.app"))
  File.write(destination_path, xml)
end

def ensure_firebase_copy_phase(target, platform)
  name = 'Copy Firebase Environment Config'
  phase = target.shell_script_build_phases.find { |item| item.name == name }
  phase ||= target.new_shell_script_build_phase(name)
  phase.input_paths = [
    "$(SRCROOT)/../firebase/$(FIREBASE_ENV)/$(FIREBASE_ROLE_PATH)#{platform}/GoogleService-Info.plist"
  ]
  phase.output_paths = ['$(TARGET_BUILD_DIR)/$(UNLOCALIZED_RESOURCES_FOLDER_PATH)/GoogleService-Info.plist']
  phase.shell_script = <<~SH
    set -euo pipefail

    FIREBASE_ENV="${FIREBASE_ENV:-prod}"
    FIREBASE_ROLE="${FIREBASE_ROLE:-consumer}"
    FIREBASE_ROLE_PATH="${FIREBASE_ROLE_PATH:-}"
    SOURCE="${SRCROOT}/../firebase/${FIREBASE_ENV}/${FIREBASE_ROLE_PATH}#{platform}/GoogleService-Info.plist"
    DEST="${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/GoogleService-Info.plist"

    if [[ ! -f "$SOURCE" ]]; then
      echo "Missing Firebase config: $SOURCE"
      exit 1
    fi

    cp "$SOURCE" "$DEST"
    echo "Copied Firebase config for $FIREBASE_ENV/$FIREBASE_ROLE to $DEST"

    INFO_PLIST="${TARGET_BUILD_DIR}/${INFOPLIST_PATH}"
    if [[ -f "$INFO_PLIST" && -x /usr/libexec/PlistBuddy ]]; then
      REVERSED_CLIENT_ID="$(/usr/libexec/PlistBuddy -c 'Print :REVERSED_CLIENT_ID' "$SOURCE" 2>/dev/null || true)"
      if [[ -n "$REVERSED_CLIENT_ID" ]]; then
        /usr/libexec/PlistBuddy -c "Set :CFBundleURLTypes:0:CFBundleURLSchemes:0 $REVERSED_CLIENT_ID" "$INFO_PLIST" 2>/dev/null || true
      fi
    fi
  SH
end

def aps_environment(mode, settings)
  mode == 'Release' && settings[:firebase_env] == 'prod' ? 'production' : 'development'
end

def app_attest_environment(mode)
  mode == 'Debug' ? 'development' : 'production'
end

def remove_static_firebase_resource(target)
  target.resources_build_phase.files.each do |build_file|
    next unless build_file.file_ref&.display_name == 'GoogleService-Info.plist'

    target.resources_build_phase.remove_build_file(build_file)
  end
end

def configure_ios
  project_path = File.join(REPO_ROOT, 'ios', 'Runner.xcodeproj')
  project = Xcodeproj::Project.open(project_path)
  runner = project.targets.find { |target| target.name == 'Runner' }
  tests = project.targets.find { |target| target.name == 'RunnerTests' }

  FLAVORS.each do |flavor, settings|
    BUILD_MODES.each do |mode, type|
      config_name = "#{mode}-#{flavor}"
      xcconfig = "Flutter/#{config_name}.xcconfig"
      pod_config = mode == 'Debug' ? 'debug' : 'release'
      File.write(
        File.join(REPO_ROOT, 'ios', xcconfig),
        <<~CONFIG
          #include? "Pods/Target Support Files/Pods-Runner/Pods-Runner.#{config_name.downcase}.xcconfig"
          #include? "Pods/Target Support Files/Pods-Runner/Pods-Runner.#{pod_config}.xcconfig"
          #include "Generated.xcconfig"
          #include "CatchBuildSettings.xcconfig"
          #include? "GoogleMapsKeys.xcconfig"
          APS_ENVIRONMENT=#{aps_environment(mode, settings)}
          APP_ATTEST_ENVIRONMENT=#{app_attest_environment(mode)}
          FIREBASE_IOS_URL_SCHEME=#{settings[:ios_url_scheme]}

          GOOGLE_MAPS_IOS_API_KEY=$(GOOGLE_MAPS_IOS_API_KEY_#{settings[:maps_key_suffix]})
        CONFIG
      )
      base_ref = ensure_file_ref(project, 'Flutter', xcconfig)
      ensure_project_config(project, config_name, type, base_ref)
      ensure_target_config(
        runner,
        config_name,
        type,
        base_ref,
        {
          'PRODUCT_BUNDLE_IDENTIFIER' => settings[:bundle_id],
          'PRODUCT_NAME' => settings[:app_name],
          'APP_DISPLAY_NAME' => settings[:app_name],
          'ASSETCATALOG_COMPILER_APPICON_NAME' => settings[:app_icon],
          'CODE_SIGN_ENTITLEMENTS' => settings[:entitlements],
          'CATCH_APP_TARGET_ID' => settings[:target_id],
          'FLUTTER_TARGET' => "$(SRCROOT)/../#{settings[:flutter_target]}",
          'FLAVOR' => flavor,
          'FIREBASE_ENV' => settings[:firebase_env],
          'FIREBASE_ROLE' => settings[:firebase_role],
          'FIREBASE_ROLE_PATH' => settings[:firebase_role_path],
          'FIREBASE_IOS_URL_SCHEME' => settings[:ios_url_scheme]
        },
        template_name: mode
      )
      ensure_target_config(
        tests,
        config_name,
        type,
        nil,
        {
          'PRODUCT_BUNDLE_IDENTIFIER' => "#{settings[:bundle_id]}.RunnerTests"
        },
        template_name: mode
      )
    end
  end

  remove_static_firebase_resource(runner)
  ensure_firebase_copy_phase(runner, 'ios')
  project.save

  scheme_dir = File.join(REPO_ROOT, 'ios', 'Runner.xcodeproj', 'xcshareddata', 'xcschemes')
  FileUtils.mkdir_p(scheme_dir)
  source_scheme = File.join(scheme_dir, 'Runner.xcscheme')
  FLAVORS.each do |flavor, settings|
    write_scheme(source_scheme, File.join(scheme_dir, "#{flavor}.xcscheme"), flavor, settings)
  end
end

def configure_macos
  project_path = File.join(REPO_ROOT, 'macos', 'Runner.xcodeproj')
  project = Xcodeproj::Project.open(project_path)
  runner = project.targets.find { |target| target.name == 'Runner' }
  tests = project.targets.find { |target| target.name == 'RunnerTests' }
  assemble = project.targets.find { |target| target.name == 'Flutter Assemble' }

  FLAVORS.each do |flavor, settings|
    BUILD_MODES.each do |mode, type|
      config_name = "#{mode}-#{flavor}"
      xcconfig = "AppInfo-#{config_name}.xcconfig"
      pod_config = mode == 'Debug' ? 'debug' : 'release'
      File.write(
        File.join(REPO_ROOT, 'macos', 'Runner', 'Configs', xcconfig),
        <<~CONFIG
          #include? "../../Pods/Target Support Files/Pods-Runner/Pods-Runner.#{config_name.downcase}.xcconfig"
          #include? "../../Pods/Target Support Files/Pods-Runner/Pods-Runner.#{pod_config}.xcconfig"
          #include "AppInfo.xcconfig"
        CONFIG
      )
      base_ref = ensure_file_ref(project, 'Runner/Configs', xcconfig)
      project_config_ref = ensure_file_ref(
        project,
        'Runner/Configs',
        mode == 'Debug' ? 'Debug.xcconfig' : 'Release.xcconfig'
      )
      ensure_project_config(project, config_name, type, project_config_ref)
      ensure_target_config(
        runner,
        config_name,
        type,
        base_ref,
        {
          'PRODUCT_BUNDLE_IDENTIFIER' => settings[:bundle_id],
          'PRODUCT_NAME' => settings[:app_name],
          'ASSETCATALOG_COMPILER_APPICON_NAME' => settings[:app_icon],
          'CATCH_APP_TARGET_ID' => settings[:target_id],
          'FLUTTER_TARGET' => "$(SRCROOT)/../#{settings[:flutter_target]}",
          'FLAVOR' => flavor,
          'FIREBASE_ENV' => settings[:firebase_env],
          'FIREBASE_ROLE' => settings[:firebase_role],
          'FIREBASE_ROLE_PATH' => settings[:firebase_role_path]
        },
        template_name: mode
      )
      ensure_target_config(
        tests,
        config_name,
        type,
        nil,
        {
          'PRODUCT_BUNDLE_IDENTIFIER' => "#{settings[:bundle_id]}.RunnerTests"
        },
        template_name: mode
      )
      ensure_target_config(assemble, config_name, type, nil, {}, template_name: mode)
    end
  end

  remove_static_firebase_resource(runner)
  ensure_firebase_copy_phase(runner, 'macos')
  project.save

  scheme_dir = File.join(REPO_ROOT, 'macos', 'Runner.xcodeproj', 'xcshareddata', 'xcschemes')
  FileUtils.mkdir_p(scheme_dir)
  source_scheme = File.join(scheme_dir, 'Runner.xcscheme')
  FLAVORS.each do |flavor, settings|
    write_scheme(source_scheme, File.join(scheme_dir, "#{flavor}.xcscheme"), flavor, settings)
  end
end

configure_ios
configure_macos
