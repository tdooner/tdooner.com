const puppeteer = require('puppeteer');

const RESUME_PATH =
  'file:///Users/tomdooner/dev/ruby/tdooner.com/build/resume.pdf.html';
(async () => {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();
  await page.goto(RESUME_PATH, { waitUntil: 'load' });
  await page.waitForFunction(() => document.fonts.status === 'loaded');
  await page.pdf({
    path: 'build/resume.pdf',
    format: 'Letter',
    margin: {
      top: '.5in',
      bottom: '.5in',

      left: '1in',
      right: '1in',
    }
  });
  console.log('Done!');

  browser.close();
})();
