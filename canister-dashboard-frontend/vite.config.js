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
            input: path.resolve(__dirname, 'src/canister-dashboard.html'),
            output: {
                entryFileNames: '[name]-[hash].js',
                chunkFileNames: '[name]-[hash].js',
                assetFileNames: '[name]-[hash].[ext]',
            },
        },
    },
    resolve: {
        alias: {
            "$candid": path.resolve(__dirname, "../candid"),
        },
    },
});
