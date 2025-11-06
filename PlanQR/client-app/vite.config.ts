/// <reference types="node" />
import { defineConfig, loadEnv } from 'vite'
import react from '@vitejs/plugin-react-swc'
import fs from 'fs'
import path, { dirname } from 'path'
import { fileURLToPath } from 'url'

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '')

  const siteUrl = env.VITE_SITE_URL // Np. https://planqr.wi.zut.edu.pl

  // Only use HTTPS for development server
  const isDev = mode === 'development'
  let serverConfig = {}
  
  if (isDev) {
    const certKeyPath = path.resolve(__dirname,'../certs/cert.key')
    const certPemPath = path.resolve(__dirname, '../certs/cert.pem')
    
    // Check if certificates exist before trying to use them
    if (fs.existsSync(certKeyPath) && fs.existsSync(certPemPath)) {
      serverConfig = {
        https: {
          key: fs.readFileSync(certKeyPath),
          cert: fs.readFileSync(certPemPath),
        },
        port: 443,
        host: true,
        proxy: {
          '/schedule_student.php': {
            target: 'https://plan.zut.edu.pl', // Możesz dodać też to do .env, jeśli chcesz
            changeOrigin: true,
            secure: false,
            rewrite: (urlPath: string) => urlPath.replace(/^\/schedule_student.php/, '/schedule_student.php'),
          },
          '/api': {
            target: siteUrl,
            changeOrigin: true,
            secure: false,
            rewrite: (urlPath: string) => urlPath.replace(/^\/api/, ''),
          },
        },
        hmr: {
          host: new URL(siteUrl).hostname, // Używa samej domeny np. planqr.wi.zut.edu.pl
          protocol: 'wss',
        },
      }
    } else {
      console.warn('HTTPS certificates not found. Run ./generate-certs.sh to create them for HTTPS development.')
      serverConfig = {
        port: 3000,
        host: true,
        proxy: {
          '/schedule_student.php': {
            target: 'https://plan.zut.edu.pl',
            changeOrigin: true,
            secure: false,
            rewrite: (urlPath: string) => urlPath.replace(/^\/schedule_student.php/, '/schedule_student.php'),
          },
          '/api': {
            target: siteUrl,
            changeOrigin: true,
            secure: false,
            rewrite: (urlPath: string) => urlPath.replace(/^\/api/, ''),
          },
        },
      }
    }
  }

  return {
    server: serverConfig,
    plugins: [react()],
  }
})