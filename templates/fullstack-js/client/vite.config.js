import gleam from "vite-gleam";
import tailwindcss from "@tailwindcss/vite";
import { viteStaticCopy } from "vite-plugin-static-copy";
import viteCompression from "vite-plugin-compression";

export default ({ mode }) => {
  const isDev = mode === "development";

  return {
    plugins: [
      gleam(),
      tailwindcss(),
      viteStaticCopy({
        targets: [
          {
            src: "index.html",
            dest: "../.templates",
          },
        ],
      }),
      viteCompression({
        verbose: false,
        disable: isDev,
        algorithm: "gzip",
        ext: ".gz",
      }),
      viteCompression({
        verbose: false,
        disable: isDev,
        algorithm: "brotliCompress",
        ext: ".br",
      }),
    ],
    server: {
      middlewareMode: true,
    },
    build: {
      outDir: "../server/priv/static",
      emptyOutDir: true,
      rollupOptions: {
        input: "./src/main.js",
        output: {
          entryFileNames: isDev ? "[name].js" : "[name]-[hash].js",
          chunkFileNames: isDev ? "[name].js" : "[name]-[hash].js",
          assetFileNames: isDev ? "[name].[ext]" : "[name]-[hash].[ext]",
        },
        onwarn(warning, warn) {
          if (warning.code === "INVALID_ANNOTATION") return;
          warn(warning);
        },
      },
      manifest: true,
      watch: isDev ? {} : null,
    },
  };
};
