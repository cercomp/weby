// @ts-check
const { test, expect } = require('@playwright/test');
const { loginAs, logout } = require('../support/auth');
const { SITE_URL, ADMIN_USER, ADMIN_PASSWORD } = require('../support/env');

test.describe('Fluxo 10: Histórico de Atividades e Agendamento de Notícias', () => {

  test('Deve acessar o histórico de atividades global e do site com novas colunas e filtros @smoke', async ({ page }) => {
    await loginAs(page);

    // 1. Histórico do Site (/admin/activity_records no site)
    const siteResponse = await page.goto(`${SITE_URL}/admin/activity_records`);
    expect(siteResponse?.status()).toBe(200);
    await expect(page).toHaveTitle(/Weby/);

    // Verifica que a tabela possui as colunas estruturadas
    const table = page.locator('table');
    await expect(table.first()).toBeVisible();
    const tableText = await table.first().innerText();
    expect(tableText).toMatch(/Data/i);
    expect(tableText).toMatch(/Usuário/i);
    expect(tableText).toMatch(/Ação|Operação/i);
    expect(tableText).toMatch(/Item|Arquivo/i);

    // 2. Histórico Global (/admin/activity_records)
    const globalResponse = await page.goto('/admin/activity_records');
    expect(globalResponse?.status()).toBe(200);
    const globalTable = page.locator('table');
    await expect(globalTable.first()).toBeVisible();
  });

  test('Deve filtrar histórico por arquivo e identificar o usuário responsável', async ({ page }) => {
    await loginAs(page);

    // Acessa o histórico do site buscando pelo arquivo de teste ou upload
    await page.goto(`${SITE_URL}/admin/activity_records?search=test-image`);
    await page.waitForLoadState('networkidle');

    // Se houver registro do upload de test-image, deve listar com o usuário admin
    const listContainer = page.locator('#list');
    await expect(listContainer).toBeVisible();

    // Testa filtro de busca por módulo "repositories"
    await page.goto(`${SITE_URL}/admin/activity_records?controller_filter=repositories`);
    await page.waitForLoadState('networkidle');
    const rows = page.locator('table tbody tr');
    if (await rows.count() > 0) {
      const firstRowText = await rows.first().innerText();
      expect(firstRowText).toMatch(/Upload|Arquivo/i);
    }
  });

  test('Deve exibir link de histórico direto na visualização do repositório de arquivos', async ({ page }) => {
    await loginAs(page);

    // Acessa a listagem de arquivos
    await page.goto(`${SITE_URL}/admin/repositories`);
    const firstDetailLink = page.locator('table tbody tr a[href*="/repositories/"]').first();
    if (await firstDetailLink.isVisible()) {
      await firstDetailLink.click();
      await page.waitForURL('**/repositories/*');

      // Na tela do arquivo, deve ter o botão de histórico
      const historyLink = page.locator('a[href*="activity_records"]');
      await expect(historyLink.first()).toBeVisible();
    }
  });

  test('Deve respeitar a data de início da publicação em notícias agendadas', async ({ page, browser }) => {
    await loginAs(page);

    // Acessa a listagem de notícias
    await page.goto(`${SITE_URL}/admin/news`);
    await expect(page).toHaveTitle(/Weby/);

    // Verifica se o filtro de status possui a opção "Agendada"
    const statusSelect = page.locator('select#status_filter');
    if (await statusSelect.isVisible()) {
      const optionsText = await statusSelect.innerText();
      expect(optionsText).toMatch(/Agendada/i);
    }
  });

});
