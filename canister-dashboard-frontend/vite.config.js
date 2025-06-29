import { defineConfig } from 'vite';
import path from 'path';

export default defineConfig({
    root: 'src',
    publicDir: '../static',
    base: '/canister-dashboard/',
    envDir: '../',
    build: {
        outDir: '../dist',
        emptyOutDir: true,
        cssCodeSplit: false,
        minify: true,

        rollupOptions: {
            input: path.resolve(__dirname, 'src/index.html'),
            output: {
                entryFileNames: '[name].js',
                chunkFileNames: '[name].js',
                assetFileNames: '[name].[ext]',
            },
        },
    },
    resolve: {
        alias: {
            "$declarations": path.resolve(__dirname, "../declarations"),
        },
    },
});
