// @ts-check
const { test, expect } = require('@playwright/test');
const { loginAs } = require('../support/auth');

test.describe('Fluxo 5: Gestão de Páginas de Conteúdo', () => {

  test.beforeEach(async ({ page }) => {
    await loginAs(page, 'admin', 'Admin1');
  });

  test('Deve acessar a listagem de páginas do site', async ({ page }) => {
    await page.goto('http://ufg.lvh.me:3000/admin/pages');
    await expect(page).toHaveTitle(/Weby/);

    const newPageBtn = page.locator('a[href*="/pages/new"], .btn-primary').first();
    await expect(newPageBtn).toBeVisible();
  });

  test('Deve abrir o formulário de criação de nova página', async ({ page }) => {
    await page.goto('http://ufg.lvh.me:3000/admin/pages/new');

    const form = page.locator('form, input[name*="title"], textarea');
    await expect(form.first()).toBeVisible();

    const submitBtn = page.locator('input[type="submit"], button[type="submit"]').first();
    await expect(submitBtn).toBeVisible();
  });

});
