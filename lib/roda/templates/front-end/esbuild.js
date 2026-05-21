const esbuild = require('esbuild');

const isWatchMode = process.argv.includes('--watch');

const entrypoints = [
  'js/app.js',
  'css/app.css'
]

function configFor(name) {
  return {
    entryPoints: [`app/assets/${name}`],
    bundle: true,
    minify: true,
    outfile: `public/${name}`,
  }
}

async function build() {
  try {
    if (isWatchMode) {
      entrypoints.forEach(async (entrypoint) => {
        const jsCtx = await esbuild.context(configFor(entrypoint));
        await jsCtx.watch();
      })
      console.log(`Watching for css and js changes in '${entrypoints.join(', ')}'...`);
    } else {
      entrypoints.forEach(async () => {
        await esbuild.build(configFor(entrypoint));
      })
      console.log(`Build complete.`);
    }
  } catch (error) {
    console.error('Build failed:', error);
    process.exit(1);
  }
}

build();
