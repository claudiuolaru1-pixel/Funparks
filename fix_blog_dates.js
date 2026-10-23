const fs = require('fs');

function patchFile(path, anchorLine, dateVarsBeforePromptLine) {
  const lines = fs.readFileSync(path, 'utf8').split('\n');
  let fixed = 0;
  for (let i = 0; i < lines.length; i++) {
    if (lines[i].includes(anchorLine)) {
      lines[i] = lines[i] + '\nToday\u0027s date is ${currentDateStr}. If a year is needed in the title, excerpt, or content, use ${currentYear} \u2014 never a past year.';
      fixed++;
    }
    if (lines[i].trim().startsWith('const prompt = `')) {
      lines[i] = dateVarsBeforePromptLine + '\n' + lines[i];
    }
  }
  fs.writeFileSync(path, lines.join('\n'), 'utf8');
  console.log(path, '- anchor patched:', fixed, 'time(s)');
}

const dateVars = "    const today = new Date();\n    const currentDateStr = today.toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' });\n    const currentYear = today.getFullYear();";

patchFile('app/api/newtopic/route.js', 'You are a theme park content strategist for Funparks app.', dateVars);
patchFile('app/agent/page.js', 'You are the content team for Funparks, a free theme park app covering 64 parks across 6 continents.', dateVars);