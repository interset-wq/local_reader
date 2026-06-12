import { chromium } from 'playwright';

const browser = await chromium.launch();
const page = await browser.newPage({ viewport: { width: 375, height: 812 } });

const errors = [];
page.on('console', msg => {
  if (msg.type() === 'error') errors.push(msg.text());
});
page.on('pageerror', err => errors.push(err.message));

await page.goto('http://localhost:5173/', { waitUntil: 'networkidle', timeout: 15000 });
await page.waitForTimeout(3000);

const bodyText = await page.evaluate(() => document.body.innerText);
console.log('=== BODY TEXT ===');
console.log(bodyText || '(empty)');
console.log('\n=== ERRORS ===');
errors.forEach(e => console.log(e));
console.log('\n=== APP DIV ===');
const appHtml = await page.evaluate(() => document.getElementById('app')?.innerHTML?.substring(0, 500));
console.log(appHtml || '(empty)');

await browser.close();
