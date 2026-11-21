// @ts-check
const { test, expect } = require('@playwright/test');
const { loginAs } = require('../support/auth');

test.describe('Fluxo 8: Menus de Navegação, Componentes e Temas', () => {

  test.beforeEach(async ({ page }) => {
    await loginAs(page, 'admin', 'Admin1');
  });

  test('Deve acessar a gestão de menus do site (/admin/menus)', async ({ page }) => {
    await page.goto('http://ufg.lvh.me:3000/admin/menus');
    await expect(page).toHaveTitle(/Weby/);

    const newMenuBtn = page.locator('a[href*="/menus/new"], .btn-primary').first();
    await expect(newMenuBtn).toBeVisible();
  });

  test('Deve carregar a página inicial do site renderizando menus sem erro 500', async ({ page }) => {
    // Acessa a raiz do site ufg
    const response = await page.goto('http://ufg.lvh.me:3000/');
    expect(response?.status()).toBe(200);

    // Valida que o layout e navegação estão visíveis
    await expect(page.locator('body')).not.toContainText(/ActionView::Template::Error/i);
    await expect(page.locator('body')).not.toContainText(/strict_loading/i);
  });

  test('Deve acessar a tela de edição de tema e paleta de cores (/admin/skins)', async ({ page }) => {
    await page.goto('http://ufg.lvh.me:3000/admin/skins');
    await expect(page).toHaveTitle(/Weby/);

    // Deve listar skins ou botões de edição de tema
    const skinActions = page.locator('a[href*="/skins/"], .skin-item, .thumbnail, table');
    await expect(skinActions.first()).toBeVisible();
  });

});
