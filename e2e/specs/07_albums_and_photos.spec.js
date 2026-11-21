// @ts-check
const { test, expect } = require('@playwright/test');
const { loginAs } = require('../support/auth');
const { SITE_URL } = require('../support/env');

test.describe('Fluxo 7: Galeria de Álbuns e Fotos', () => {

  test.beforeEach(async ({ page }) => {
    await loginAs(page);
  });

  test('Deve acessar a listagem de álbuns de fotos @smoke', async ({ page }) => {
    const response = await page.goto(`${SITE_URL}/admin/albums`);
    expect(response?.status()).toBe(200);
    await expect(page).toHaveTitle(/Weby/);

    const newAlbumBtn = page.locator('a[href*="/albums/new"], .btn-primary').first();
    await expect(newAlbumBtn).toBeVisible();
  });

  test('Deve abrir o formulário para cadastro de novo álbum @smoke', async ({ page }) => {
    const response = await page.goto(`${SITE_URL}/admin/albums/new`);
    expect(response?.status()).toBe(200);

    const form = page.locator('form#new_album, form');
    await expect(form.first()).toBeVisible();

    const slugInput = page.locator('input[name*="slug"], input#album_slug').first();
    await expect(slugInput).toBeVisible();

    const submitBtn = page.locator('input[type="submit"], button[type="submit"]').first();
    await expect(submitBtn).toBeVisible();
  });

});
