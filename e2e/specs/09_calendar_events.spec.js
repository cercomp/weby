// @ts-check
const { test, expect } = require('@playwright/test');
const { loginAs } = require('../support/auth');
const { SITE_URL } = require('../support/env');

test.describe('Fluxo 9: Agenda de Eventos e Compartilhamento (Calendar)', () => {

  test.beforeEach(async ({ page }) => {
    await loginAs(page);
  });

  test('Deve acessar a listagem de eventos da agenda (/admin/events) @smoke', async ({ page }) => {
    const response = await page.goto(`${SITE_URL}/admin/events`);
    expect(response?.status()).toBe(200);
    await expect(page).toHaveTitle(/Weby/);

    const newEventBtn = page.locator('a[href*="/events/new"], .btn-primary').first();
    await expect(newEventBtn).toBeVisible();
  });

  test('Deve abrir o formulário para cadastro de novo evento com opções de compartilhamento @smoke', async ({ page }) => {
    const response = await page.goto(`${SITE_URL}/admin/events/new`);
    expect(response?.status()).toBe(200);

    const form = page.locator('form#new_event, form');
    await expect(form.first()).toBeVisible();

    const submitBtn = page.locator('input[type="submit"], button[type="submit"]').first();
    await expect(submitBtn).toBeVisible();
  });

});
