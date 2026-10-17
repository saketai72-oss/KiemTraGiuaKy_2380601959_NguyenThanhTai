const fs = require('fs');
const path = require('path');

const config = JSON.parse(fs.readFileSync('bundles.json', 'utf8'));

// 1. Process scripts
for (const item of config.scripts) {
  const outPath = path.join('wwwroot', item.output);
  fs.mkdirSync(path.dirname(outPath), { recursive: true });
  let content = '';
  for (const f of item.input) {
    if (fs.existsSync(f)) {
      content += '\n/* --- ' + f + ' --- */\n' + fs.readFileSync(f, 'utf8') + ';\n';
    }
  }
  fs.writeFileSync(outPath, content, 'utf8');
  console.log('Created script bundle:', outPath, '(' + content.length + ' bytes)');
}

// 2. Process styles
for (const item of config.styles) {
  const outPath = path.join('wwwroot', item.output);
  fs.mkdirSync(path.dirname(outPath), { recursive: true });
  let content = '';
  for (const f of item.input) {
    if (fs.existsSync(f)) {
      content += '\n/* --- ' + f + ' --- */\n' + fs.readFileSync(f, 'utf8') + '\n';
    }
  }
  fs.writeFileSync(outPath, content, 'utf8');
  console.log('Created style bundle:', outPath, '(' + content.length + ' bytes)');
}

// 3. Copy webfonts
const srcWebfonts = 'node_modules/@fortawesome/fontawesome-free/webfonts';
if (fs.existsSync(srcWebfonts)) {
  const targets = [
    'wwwroot/webfonts',
    'wwwroot/view-resources/Views/_Bundles/webfonts',
    'wwwroot/view-resources/Views/webfonts'
  ];
  for (const t of targets) {
    fs.mkdirSync(t, { recursive: true });
    for (const file of fs.readdirSync(srcWebfonts)) {
      fs.copyFileSync(path.join(srcWebfonts, file), path.join(t, file));
    }
    console.log('Copied webfonts to:', t);
  }
}

// 4. Copy view-resources .js to .min.js and .css to .min.css
function copyRecursive(dir) {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      if (entry.name !== '_Bundles') copyRecursive(full);
    } else if (entry.isFile()) {
      if (entry.name.endsWith('.js') && !entry.name.endsWith('.min.js')) {
        const minPath = full.replace(/\.js$/, '.min.js');
        if (!fs.existsSync(minPath)) {
          fs.copyFileSync(full, minPath);
        }
      }
      if (entry.name.endsWith('.css') && !entry.name.endsWith('.min.css')) {
        const minPath = full.replace(/\.css$/, '.min.css');
        if (!fs.existsSync(minPath)) {
          fs.copyFileSync(full, minPath);
        }
      }
    }
  }
}
copyRecursive('wwwroot/view-resources');
console.log('Bundling completed successfully!');
