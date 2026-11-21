// @ts-check
const { test, expect } = require('@playwright/test');
const { loginAs } = require('../support/auth');
const { SITE_URL } = require('../support/env');

test.describe('Fluxo 8: Menus de Navegação, Componentes e Temas', () => {

  test.beforeEach(async ({ page }) => {
    await loginAs(page);
  });

  test('Deve acessar a gestão de menus do site (/admin/menus) @smoke', async ({ page }) => {
    const response = await page.goto(`${SITE_URL}/admin/menus`);
    expect(response?.status()).toBe(200);
    await expect(page).toHaveTitle(/Weby/);

    const newMenuBtn = page.locator('a[href*="/menus/new"], .btn-primary').first();
    await expect(newMenuBtn).toBeVisible();
  });

  test('Deve carregar a página inicial do site renderizando menus sem erro 500 @smoke', async ({ page }) => {
    // Acessa a raiz do site institucional
    const response = await page.goto(`${SITE_URL}/`);
    expect(response?.status()).toBe(200);

    // Valida que o layout e navegação estão visíveis
    await expect(page.locator('body')).not.toContainText(/ActionView::Template::Error/i);
    await expect(page.locator('body')).not.toContainText(/strict_loading/i);
  });

  test('Deve acessar a tela de edição de tema e paleta de cores (/admin/skins) @smoke', async ({ page }) => {
    const response = await page.goto(`${SITE_URL}/admin/skins`);
    expect(response?.status()).toBe(200);
    await expect(page).toHaveTitle(/Weby/);

    // Deve listar skins ou botões de edição de tema
    const skinActions = page.locator('a[href*="/skins/"], .skin-item, .thumbnail, table');
    await expect(skinActions.first()).toBeVisible();
  });

});
