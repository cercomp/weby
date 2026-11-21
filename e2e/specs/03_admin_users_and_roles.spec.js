// @ts-check
const { test, expect } = require('@playwright/test');
const { loginAs } = require('../support/auth');

test.describe('Fluxo 3: Painel Administrativo Global, Usuários e Papéis', () => {

  test.beforeEach(async ({ page }) => {
    await loginAs(page, 'admin', 'Admin1');
  });

  test('Deve acessar o dashboard administrativo principal (/admin)', async ({ page }) => {
    await page.goto('/admin');
    await expect(page).toHaveURL(/.*admin/);
    
    // Menu lateral ou de topo com opções administrativas
    await expect(page.locator('a[href*="/admin/users"], a[href*="/admin/sites"]').first()).toBeVisible();
  });

  test('Deve carregar a listagem de usuários com paginação sem erros 500 (/admin/users)', async ({ page }) => {
    const response = await page.goto('/admin/users');
    expect(response?.status()).toBe(200);

    // Tabela de usuários deve estar visível
    const usersTable = page.locator('table, .table');
    await expect(usersTable.first()).toBeVisible();

    // Deve exibir o usuário admin logado
    await expect(page.locator('body')).toContainText(/admin/);
  });

  test('Deve visualizar a matriz de papéis e permissões (/admin/roles)', async ({ page }) => {
    const response = await page.goto('/admin/roles');
    expect(response?.status()).toBe(200);

    // Deve listar os perfis cadastrados no sistema (Gestor, Gerente, etc)
    const bodyText = await page.innerText('body');
    expect(bodyText).toMatch(/Gestor|Gerente|Administrador|Editor/i);
  });

  test('Deve acessar as configurações do sistema (/admin/settings)', async ({ page }) => {
    const response = await page.goto('/admin/settings');
    expect(response?.status()).toBe(200);

    await expect(page.locator('form, input, select').first()).toBeVisible();
  });

});
