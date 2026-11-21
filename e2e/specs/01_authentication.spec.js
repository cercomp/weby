// @ts-check
const { test, expect } = require('@playwright/test');
const { loginAs, logout } = require('../support/auth');

test.describe('Fluxo 1: Autenticação e Gestão de Sessão', () => {

  test('Deve realizar login com credenciais de administrador com sucesso', async ({ page, context }) => {
    await page.goto('/login');
    await expect(page).toHaveTitle(/Weby/);

    // Preenche credenciais válidas
    await page.fill('#user_auth', 'admin');
    await page.fill('#user_password', 'Admin1');
    await page.click('form#new_user input[type="submit"]');

    // Verifica que o login foi bem sucedido e redirecionou para a home
    await page.waitForURL('**/');
    const userArea = page.locator('.user-profile-header, .user, a[href*="logout"]');
    await expect(userArea.first()).toBeVisible();

    // Valida que o cookie de sessão do domínio .lvh.me foi devidamente atribuído
    const cookies = await context.cookies();
    const sessionCookie = cookies.find(c => c.name.includes('sess'));
    expect(sessionCookie).toBeDefined();
    expect(sessionCookie?.domain).toContain('lvh.me');
  });

  test('Deve exibir erro amigável ao tentar login com senha inválida', async ({ page }) => {
    await page.goto('/login');

    await page.fill('#user_auth', 'admin');
    await page.fill('#user_password', 'SenhaTotalmenteErrada123');
    await page.click('form#new_user input[type="submit"]');

    // Permanece na tela de login e exibe alerta de erro
    await expect(page).toHaveURL(/.*login/);
    const alert = page.locator('.alert-danger, .flash-alert, .alert');
    await expect(alert.first()).toBeVisible();
    await expect(alert.first()).toContainText(/inválid/i);
  });

  test('Deve manter a sessão autenticada ao navegar entre páginas', async ({ page }) => {
    await loginAs(page, 'admin', 'Admin1');

    // Navega para a área administrativa
    await page.goto('/admin');
    await expect(page).toHaveURL(/.*admin/);
    await expect(page.locator('a[href*="logout"], a.btn-logout').first()).toBeVisible();

    // Navega de volta para a raiz
    await page.goto('/');
    await expect(page.locator('a[href*="logout"], a.btn-logout').first()).toBeVisible();
  });

  test('Deve realizar logout e encerrar a sessão do usuário', async ({ page, context }) => {
    await loginAs(page, 'admin', 'Admin1');

    // Clica no link de logout
    const logoutBtn = page.locator('a[href*="logout"], a.btn-logout').first();
    await logoutBtn.click();

    // Deve voltar a exibir os botões de Login / Cadastro
    await expect(page.locator('a[href*="login"]').first()).toBeVisible();
  });

});
