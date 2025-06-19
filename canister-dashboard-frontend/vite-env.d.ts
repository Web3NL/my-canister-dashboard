/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_IDENTITY_PROVIDER?: string
  readonly VITE_HOSTNAME?: string
}

interface ImportMeta {
  readonly env: ImportMetaEnv
}