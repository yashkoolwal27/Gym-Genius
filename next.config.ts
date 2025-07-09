import type {NextConfig} from 'next';

const nextConfig: NextConfig = {
  /* config options here */
  typescript: {
    ignoreBuildErrors: true,
  },
  eslint: {
    ignoreDuringBuilds: true,
  },
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: 'placehold.co',
        port: '',
        pathname: '/**',
      },
      {
        protocol: 'https',
        hostname: 'images.unsplash.com',
        port: '',
        pathname: '/**',
      },
      {
        protocol: 'https',
        hostname: 'cdn.shopify.com',
        port: '',
        pathname: '/**',
      },
      {
        protocol: "https",
        hostname: "gymvisual.com",
      },
    ],
  },
  // INJECTED: This is a temporary workaround for a known issue with Next.js
  // and Turbopack. This can be removed in a future Next.js version.
  experimental: {
    allowedDevOrigins: [
      'https://6000-firebase-studio-1751916238080.cluster-ys234awlzbhwoxmkkse6qo3fz6.cloudworkstations.dev',
    ],
  },
};

export default nextConfig;
