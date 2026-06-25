import { readFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(__dirname, '../../../..');
const pocRoot = path.resolve(__dirname, '..');
const contractPath = path.join(pocRoot, 'design', 'primitives.contract.json');

const contract = JSON.parse(await readFile(contractPath, 'utf8'));
const errors = [];
const notices = [];

function repoPath(relativePath) {
  return path.join(repoRoot, relativePath);
}

async function readRepoFile(relativePath, label = relativePath) {
  try {
    return await readFile(repoPath(relativePath), 'utf8');
  } catch {
    errors.push(`Missing referenced ${label}: ${relativePath}`);
    return null;
  }
}

if (contract.policy?.mode !== 'reference_only') {
  errors.push('Contract policy.mode must be reference_only');
}

if (contract.canvas?.width !== 1080 || contract.canvas?.height !== 1350) {
  errors.push('Canvas must reference Instagram 4:5 dimensions: 1080x1350');
}

if (contract.logo?.requiredWordmark !== 'Catch _') {
  errors.push('Logo requiredWordmark must be exactly "Catch _"');
}

if (!contract.logo?.sourceAsset && !contract.logo?.sourceComponent) {
  if (contract.logo?.sourceStatus !== 'missing_source') {
    errors.push('Missing logo source must be declared with sourceStatus: missing_source');
  } else {
    notices.push('Logo source is missing: rendering remains blocked until a real Catch _ asset or component is referenced.');
  }
}

for (const reference of Object.values(contract.typography?.roleReferences ?? {})) {
  const content = await readRepoFile(reference.file, `typography role ${reference.symbol}`);
  if (content && !content.includes(reference.symbol.split('.').at(-1))) {
    errors.push(`Typography symbol not found in ${reference.file}: ${reference.symbol}`);
  }
}

const fontRegistry = contract.typography?.fontRegistryReference;
if (fontRegistry) {
  const content = await readRepoFile(fontRegistry.file, 'font registry');
  for (const symbol of fontRegistry.symbols ?? []) {
    if (content && !content.includes(symbol.split('.').at(-1))) {
      errors.push(`Font registry symbol not found in ${fontRegistry.file}: ${symbol}`);
    }
  }
}

const tokenContent = await readRepoFile(contract.colors?.tokenSource, 'token source');
for (const token of [
  ...(contract.colors?.themeReferences ?? []),
  ...(contract.colors?.activityReferences ?? []),
]) {
  const likelyKey = token.split('.').at(-1);
  if (tokenContent && !tokenContent.includes(likelyKey)) {
    errors.push(`Token reference key not found in ${contract.colors.tokenSource}: ${token}`);
  }
}

const componentRegistryContent = await readRepoFile(
  'design/components/catch.components.json',
  'component registry',
);

for (const reference of contract.components?.references ?? []) {
  if (componentRegistryContent && !componentRegistryContent.includes(`"id": "${reference.contractId}"`)) {
    errors.push(`Component contract id not found: ${reference.contractId}`);
  }
  const runtimeContent = await readRepoFile(reference.runtimeFile, `runtime component ${reference.runtimeSymbol}`);
  if (runtimeContent && !runtimeContent.includes(`class ${reference.runtimeSymbol}`)) {
    errors.push(`Runtime component symbol not found in ${reference.runtimeFile}: ${reference.runtimeSymbol}`);
  }
}

if (errors.length > 0) {
  console.error('Brand reference validation failed:');
  for (const error of errors) {
    console.error(`- ${error}`);
  }
  process.exit(1);
}

console.log('Brand reference contract ok: references existing Catch text styles, tokens, and component primitives.');
for (const notice of notices) {
  console.log(`Notice: ${notice}`);
}
