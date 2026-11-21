// @ts-check

/**
 * Environment configuration for Weby E2E tests.
 * Values can be customized via environment variables:
 *
 *   BASE_URL=https://portais-homolog.weby.ufg.br \
 *   SITE_URL=https://ufg-homolog.weby.ufg.br \
 *   ADMIN_USER=seu_usuario \
 *   ADMIN_PASSWORD=sua_senha \
 *   npm run test:e2e
 */

const BASE_URL = process.env.BASE_URL || 'http://portais.lvh.me:3000';
const SITE_URL = process.env.SITE_URL || 'http://ufg.lvh.me:3000';
const ADMIN_USER = process.env.ADMIN_USER || 'admin';
const ADMIN_PASSWORD = process.env.ADMIN_PASSWORD || 'Admin1';
const EXPECTED_COOKIE_DOMAIN = process.env.COOKIE_DOMAIN || null;

/**
 * Helper to get the base domain from a URL string (e.g. 'portais.lvh.me:3000' -> 'lvh.me')
 * @param {string} urlString
 * @returns {string}
 */
function getBaseDomain(urlString) {
  try {
    const parsed = new URL(urlString);
    const host = parsed.hostname;
    const parts = host.split('.');
    if (parts.length >= 2) {
      return parts.slice(-2).join('.');
    }
    return host;
  } catch {
    return 'lvh.me';
  }
}

module.exports = {
  BASE_URL,
  SITE_URL,
  ADMIN_USER,
  ADMIN_PASSWORD,
  EXPECTED_COOKIE_DOMAIN,
  getBaseDomain,
};
