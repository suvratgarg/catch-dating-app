#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'xcodeproj'

REPO_ROOT = File.expand_path('..', __dir__)

FLAVORS = {
  'dev' => {
    bundle_id: 'com.catchdates.app.dev',
    app_name: 'Catch Dev',
    firebase_env: 'dev'
  },
  'staging' => {
    bundle_id: 'com.catchdates.app.staging',
    app_name: 'Catch Staging',
    firebase_env: 'staging'
  },
  'prod' => {
    bundle_id: 'com.catchdates.app',
    app_name: 'Catch',
    firebase_env: 'prod'
  }
}.freeze

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
  config ||= target.add_build_configuration(name, type)
  config.base_configuration_reference = base_ref if base_ref
  if template_name
    template = target.build_configurations.find { |item| item.name == template_name }
    config.build_settings.merge!(template.build_settings) if template
  end
  config.build_settings.merge!(build_settings)
  config
end

def write_scheme(source_scheme_path, destination_path, flavor)
  xml = File.read(source_scheme_path)
  BUILD_MODES.each_key do |mode|
    xml = xml.gsub(%(buildConfiguration = "#{mode}"), %(buildConfiguration = "#{mode}-#{flavor}"))
  end
  File.write(destination_path, xml)
end

def ensure_firebase_copy_phase(target, platform)
  name = 'Copy Firebase Environment Config'
  phase = target.shell_script_build_phases.find { |item| item.name == name }
  phase ||= target.new_shell_script_build_phase(name)
  phase.input_paths = ["$(SRCROOT)/../firebase/$(FIREBASE_ENV)/#{platform}/GoogleService-Info.plist"]
  phase.output_paths = ['$(TARGET_BUILD_DIR)/$(UNLOCALIZED_RESOURCES_FOLDER_PATH)/GoogleService-Info.plist']
  phase.shell_script = <<~SH
    set -euo pipefail

    FIREBASE_ENV="${FIREBASE_ENV:-prod}"
    SOURCE="${SRCROOT}/../firebase/${FIREBASE_ENV}/#{platform}/GoogleService-Info.plist"
    DEST="${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/GoogleService-Info.plist"

    if [[ ! -f "$SOURCE" ]]; then
      echo "Missing Firebase config: $SOURCE"
      exit 1
    fi

    cp "$SOURCE" "$DEST"
    echo "Copied Firebase config for $FIREBASE_ENV to $DEST"
  SH
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
          'APP_DISPLAY_NAME' => settings[:app_name],
          'FIREBASE_ENV' => settings[:firebase_env]
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
  FLAVORS.each_key do |flavor|
    write_scheme(source_scheme, File.join(scheme_dir, "#{flavor}.xcscheme"), flavor)
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
          'FIREBASE_ENV' => settings[:firebase_env]
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
  FLAVORS.each_key do |flavor|
    write_scheme(source_scheme, File.join(scheme_dir, "#{flavor}.xcscheme"), flavor)
  end
end

configure_ios
configure_macos
