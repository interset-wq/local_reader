import { chromium } from 'playwright';

const browser = await chromium.launch();
const page = await browser.newPage({ viewport: { width: 375, height: 812 } });

const allLogs = [];
page.on('console', msg => allLogs.push(`[${msg.type()}] ${msg.text()}`));
page.on('pageerror', err => allLogs.push(`[PAGE ERROR] ${err.message}`));

// Capture network errors
page.on('requestfailed', req => allLogs.push(`[NET FAIL] ${req.url()} ${req.failure()?.errorText}`));
page.on('response', res => {
  if (res.status() >= 400) allLogs.push(`[HTTP ${res.status()}] ${res.url()}`);
});

await page.goto('http://localhost:5173/', { waitUntil: 'networkidle', timeout: 15000 });
await page.waitForTimeout(5000);

console.log('=== ALL LOGS ===');
allLogs.forEach(l => console.log(l));

const appHtml = await page.evaluate(() => document.getElementById('app')?.innerHTML);
console.log('\n=== APP HTML (first 1000 chars) ===');
console.log(appHtml?.substring(0, 1000) || '(empty)');

await browser.close();
