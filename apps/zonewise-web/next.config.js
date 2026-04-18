// next.config.js
// SUMMIT 77c39794 — security headers for parcel card routes
// EG14 point 6 (Security Headers) — critical gate
// Supersedes any prior headers() config for these paths

/** @type {import('next').NextConfig} */
module.exports = {
  async headers() {
    const commonSecurity = [
      { key: 'X-Content-Type-Options', value: 'nosniff' },
      { key: 'X-Frame-Options', value: 'DENY' },
      { key: 'Referrer-Policy', value: 'strict-origin-when-cross-origin' },
      { key: 'Permissions-Policy', value: 'camera=(), microphone=(), geolocation=(self)' },
      { key: 'Strict-Transport-Security', value: 'max-age=63072000; includeSubDomains; preload' },
      {
        key: 'Content-Security-Policy',
        value: [
          "default-src 'self'",
          // Inline styles kept for CSS-in-JS until migration to CSS modules; inline scripts limited to the ld+json and the view-pixel
          "script-src 'self' 'unsafe-inline'",
          "style-src 'self' 'unsafe-inline' https://rsms.me",
          "font-src 'self' https://rsms.me data:",
          "img-src 'self' data: blob: https://*.supabase.co https://*.mapbox.com",
          "connect-src 'self' https://mocerqjnksmhcjzxrewo.supabase.co https://api.mapbox.com",
          "frame-ancestors 'none'",
          "base-uri 'self'",
          "form-action 'self' https://chat.zonewise.ai https://biddeed.ai",
        ].join('; '),
      },
    ];
    return [
      // Lock down public parcel card routes
      { source: '/parcel/:id*', headers: commonSecurity },
      { source: '/property/:id*', headers: commonSecurity }, // BidDeed mirror
    ];
  },
};
