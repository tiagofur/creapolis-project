import { test, expect } from '@playwright/test';

test('has title', async ({ page }) => {
    await page.goto('/');

    // Expect a title "to contain" a substring.
    // Adjust this to match your actual app title
    await expect(page).toHaveTitle(/Creapolis|Landing/);
});

test('get started link', async ({ page }) => {
    await page.goto('/');

    // Click the get started link.
    // Adjust the locator to match an actual element in your landing page
    // await page.getByRole('link', { name: 'Get started' }).click();

    // Expects page to have a heading with the name of Installation.
    // await expect(page.getByRole('heading', { name: 'Installation' })).toBeVisible();
});
