// @ts-check
const { expect } = require('@playwright/test');

/**
 * Helper to log into Weby with given credentials.
 * @param {import('@playwright/test').Page} page
 * @param {string} login
 * @param {string} password
 */
async function loginAs(page, login = 'admin', password = 'Admin1') {
  await page.goto('/login');
  
  // Fill in login credentials
  await page.fill('#user_auth', login);
  await page.fill('#user_password', password);
  
  // Submit the form
  await page.click('form#new_user input[type="submit"]');
  
  // Wait until navigation finishes and user profile / logout link is visible
  await expect(page.locator('a[href*="logout"], a.btn-logout, .user-actions')).toBeVisible({ timeout: 10000 });
}

/**
 * Helper to perform logout.
 * @param {import('@playwright/test').Page} page
 */
async function logout(page) {
  const logoutBtn = page.locator('a[href*="logout"], a.btn-logout');
  if (await logoutBtn.isVisible()) {
    await logoutBtn.click();
    await page.waitForLoadState('networkidle');
  }
}

module.exports = {
  loginAs,
  logout
};
