// @ts-check
const { test, expect } = require('@playwright/test');
const { loginAs } = require('../support/auth');
const { SITE_URL } = require('../support/env');

test.describe('Fluxo 5: Gestão de Páginas de Conteúdo', () => {

  test.beforeEach(async ({ page }) => {
    await loginAs(page);
  });

  test('Deve acessar a listagem de páginas do site @smoke', async ({ page }) => {
    const response = await page.goto(`${SITE_URL}/admin/pages`);
    expect(response?.status()).toBe(200);
    await expect(page).toHaveTitle(/Weby/);

    const newPageBtn = page.locator('a[href*="/pages/new"], .btn-primary').first();
    await expect(newPageBtn).toBeVisible();
  });

  test('Deve abrir o formulário de criação de nova página @smoke', async ({ page }) => {
    const response = await page.goto(`${SITE_URL}/admin/pages/new`);
    expect(response?.status()).toBe(200);

    const form = page.locator('form, input[name*="title"], textarea');
    await expect(form.first()).toBeVisible();

    const submitBtn = page.locator('input[type="submit"], button[type="submit"]').first();
    await expect(submitBtn).toBeVisible();
  });

});
