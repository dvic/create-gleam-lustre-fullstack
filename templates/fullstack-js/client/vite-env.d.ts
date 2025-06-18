/// <reference types="vite/client" />

declare module "@tailwindcss/vite" {
  import { Plugin } from "vite";
  const tailwindcss: () => Plugin;
  export default tailwindcss;
}
