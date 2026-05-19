const esbuild = require('esbuild');

const isWatchMode = process.argv.includes('--watch');

const entrypoints = [
  'app'
]

function jsConfigFor(name) {
  return {
    entryPoints: [`app/assets/js/${name}.js`],
    bundle: true,
    minify: true,
    sourcemap: true,
    outfile: `public/js/${name}.min.js`,
  }
}

function cssConfigFor(name) {
  return {
    entryPoints: [`app/assets/css/${name}.css`],
    bundle: true,
    minify: true,
    outfile: `public/css/${name}.min.css`,
  }
}

async function build() {
  try {
    if (isWatchMode) {
      entrypoints.forEach(async (entrypoint) => {
        const jsCtx = await esbuild.context(jsConfigFor(entrypoint));
        await jsCtx.watch();
        const cssCtx = await esbuild.context(cssConfigFor(entrypoint));
        await cssCtx.watch();
      })
      console.log(`Watching for css and js changes in '${entrypoints.join(', ')}'...`);
    } else {
      entrypoints.forEach(async () => {
        await esbuild.build(jsConfigFor(entrypoint));
        await esbuild.build(cssConfigFor(entrypoint));
      })
      console.log(`Build complete.`);
    }
  } catch (error) {
    console.error('Build failed:', error);
    process.exit(1);
  }
}

build();
