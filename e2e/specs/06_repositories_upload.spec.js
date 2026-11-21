// @ts-check
const { test, expect } = require('@playwright/test');
const path = require('path');
const { loginAs } = require('../support/auth');

test.describe('Fluxo 6: Repositório de Arquivos e Uploads', () => {

  test.beforeEach(async ({ page }) => {
    await loginAs(page, 'admin', 'Admin1');
  });

  test('Deve acessar a listagem de arquivos do repositório', async ({ page }) => {
    await page.goto('http://ufg.lvh.me:3000/admin/repositories');
    await expect(page).toHaveTitle(/Weby/);

    const uploadBtn = page.locator('a[href*="/repositories/new"], .btn-primary').first();
    await expect(uploadBtn).toBeVisible();
  });

  test('Deve abrir a tela de upload e enviar uma imagem com sucesso (sem spoofing)', async ({ page }) => {
    await page.goto('http://ufg.lvh.me:3000/admin/repositories/new');

    const fileInput = page.locator('input[type="file"]').first();
    await expect(fileInput).toBeAttached();

    // Carrega a imagem de teste
    const filePath = path.resolve(__dirname, '../fixtures/test-image.png');
    await fileInput.setInputFiles(filePath);

    // Preenche descrição textual obrigatória se houver
    const descInput = page.locator('input[name*="description"], textarea[name*="description"]').first();
    if (await descInput.isVisible()) {
      await descInput.fill('Imagem de Teste E2E Playwright');
    }

    // Submete o upload
    const submitBtn = page.locator('input[type="submit"], button[type="submit"]').first();
    await submitBtn.click();

    // Não deve conter mensagem de erro de spoofed media type
    await expect(page.locator('body')).not.toContainText(/spoofed_media_type/i);
  });

});
