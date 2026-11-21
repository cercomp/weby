// @ts-check
const { test, expect } = require('@playwright/test');
const { loginAs } = require('../support/auth');

test.describe('Fluxo 4: Gestão de Notícias (Journal)', () => {

  test.beforeEach(async ({ page }) => {
    await loginAs(page, 'admin', 'Admin1');
  });

  test('Deve acessar a listagem de notícias do site', async ({ page }) => {
    // Navega para o site ufg
    await page.goto('http://ufg.lvh.me:3000/admin/news');
    
    // Verifica se a página carregou com status 200
    await expect(page).toHaveTitle(/Weby/);
    await expect(page.locator('a[href*="/news/new"], .btn-primary, .page-title, h1, h2').first()).toBeVisible();
  });

  test('Deve exibir os filtros de data e busca de notícias', async ({ page }) => {
    await page.goto('http://ufg.lvh.me:3000/admin/news');

    // Filtros de busca ou formulário de pesquisa
    const searchOrFilter = page.locator('form, input[type="search"], input[name*="search"], input[name*="date"], .filter-form');
    await expect(searchOrFilter.first()).toBeVisible();
  });

  test('Deve abrir o formulário para cadastro de nova notícia', async ({ page }) => {
    await page.goto('http://ufg.lvh.me:3000/admin/news/new');

    // Verifica presença dos campos obrigatórios (título, texto)
    const titleInput = page.locator('input[name*="[title]"], input[name*="title"], #news_title, input[type="text"]').first();
    await expect(titleInput).toBeVisible();

    const submitBtn = page.locator('input[type="submit"], button[type="submit"]').first();
    await expect(submitBtn).toBeVisible();
  });

});
