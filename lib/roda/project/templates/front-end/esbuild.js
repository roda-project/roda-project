const esbuild = require('esbuild');
const manifestPlugin = require('esbuild-plugin-manifest');
const isWatchMode = process.argv.includes('--watch');
const isProduction = process.env.RACK_ENV === 'production';

const cssEntryPoints = ['app']
const jsEntryPoints = ['app']

function config() {
  const assetsEntryPoints =
    cssEntryPoints.map((e) => `css/${e}.css`)
    .concat(
      jsEntryPoints.map((e) => `js/${e}.js`)
    )

  return {
    entryPoints: assetsEntryPoints.map((name) => `app/assets/${name}`),
    bundle: true,
    minify: isProduction,
    outdir: "public/assets",
    entryNames: isProduction ? '[name]-[hash]' : '[name]',
    plugins: isProduction ? [
      manifestPlugin({ shortNames: true })
    ] : [],
  }
}

async function build() {
  try {
    if (isWatchMode) {
      const ctx = await esbuild.context(config());
      await ctx.watch();

      console.log(`Watching for css and js changes in '${assetsEntryPoints.join(', ')}'...`);
    } else {
      await esbuild.build(config());

      console.log(`Build complete.`);
    }
  } catch (error) {
    console.error('Build failed:', error);
    process.exit(1);
  }
}

build();
