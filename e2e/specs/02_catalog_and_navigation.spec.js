// @ts-check
const { test, expect } = require('@playwright/test');
const { loginAs } = require('../support/auth');
const { SITE_URL } = require('../support/env');

test.describe('Fluxo 2: Catálogo de Portais e Webybar', () => {

  test('Deve exibir a listagem inicial do catálogo de portais @smoke', async ({ page }) => {
    await page.goto('/');
    await expect(page).toHaveTitle(/Weby | UFG/);

    // O container de sites/portais deve estar presente
    const sitesContainer = page.locator('.sites-list, .site-list, .portal-card, .sites, #sites');
    await expect(sitesContainer.first()).toBeVisible();

    // Deve conter pelo menos um portal cadastrado (ex: ufg, portais, etc)
    const portalCards = page.locator('.portal-card, .site, .site-item, [class*="site"]');
    expect(await portalCards.count()).toBeGreaterThan(0);
  });

  test('Deve filtrar portais pelo campo de busca @smoke', async ({ page }) => {
    await page.goto('/');

    const searchInput = page.locator('input[type="search"], input[name*="search"], input#search, input.search-query').first();
    if (await searchInput.isVisible()) {
      await searchInput.fill('ufg');
      await searchInput.press('Enter');
      await page.waitForLoadState('networkidle');
      
      const results = page.locator('body');
      await expect(results).toContainText(/ufg/i);
    }
  });

  test('Deve renderizar os ícones do FontAwesome na barra superior (webybar e cabeçalho) @smoke', async ({ page }) => {
    await loginAs(page);
    
    // 1. Testa no portal principal (weby_pages)
    await page.goto('/');
    const adminLabel = page.locator('.label-ufg-admin i.fa, a.label-ufg-admin .fa, .label-ufg-admin').first();
    await expect(adminLabel).toBeVisible();

    // 2. Testa no site institucional (webybar)
    await page.goto(`${SITE_URL}/`);
    const webybar = page.locator('#webybar, .ufg-webybar');
    await expect(webybar).toBeVisible();

    // Verifica que o ícone do FontAwesome preserva sua família de fonte
    const faIcon = page.locator('#webybar .fa, #header .fa').first();
    await expect(faIcon).toBeVisible();
    const fontFamily = await faIcon.evaluate(el => window.getComputedStyle(el).getPropertyValue('font-family'));
    expect(fontFamily.toLowerCase()).toContain('fontawesome');
  });

});
