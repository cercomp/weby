// @ts-check
const { test, expect } = require('@playwright/test');
const path = require('path');
const { loginAs } = require('../support/auth');
const { SITE_URL } = require('../support/env');

test.describe('Fluxo 6: Repositório de Arquivos e Uploads', () => {

  test.beforeEach(async ({ page }) => {
    await loginAs(page);
  });

  test('Deve acessar a listagem de arquivos do repositório @smoke', async ({ page }) => {
    const response = await page.goto(`${SITE_URL}/admin/repositories`);
    expect(response?.status()).toBe(200);
    await expect(page).toHaveTitle(/Weby/);

    const uploadBtn = page.locator('a[href*="/repositories/new"], .btn-primary').first();
    await expect(uploadBtn).toBeVisible();
  });

  test('Deve abrir a tela de upload e enviar uma imagem com sucesso (sem spoofing)', async ({ page }) => {
    await page.goto(`${SITE_URL}/admin/repositories/new`);

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
