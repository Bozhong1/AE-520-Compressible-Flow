#!/usr/bin/env node
// Render the current LaTeX solution content with literal KaTeX math and Chromium.
// This is an HTML/PDF rendering route, not a LaTeX compiler.
// Dependencies: Node.js, katex, playwright, and a Chromium-compatible browser.
// npm install katex@0.19.0 playwright
// node node/render_submission.cjs --chrome /path/to/chrome
// Optional: --katex-dir DIR --playwright-dir DIR --out FILE --audit FILE --html FILE
const fs=require('fs'),path=require('path'),os=require('os'),crypto=require('crypto');
const {pathToFileURL}=require('url');
const args={};for(let i=2;i<process.argv.length;i+=2){if(!process.argv[i].startsWith('--')||!process.argv[i+1])throw Error('Expected --option value');args[process.argv[i].slice(2)]=process.argv[i+1];}
const katex=require(args['katex-dir']||'katex');
const {chromium}=require(args['playwright-dir']||'playwright');
const ROOT=path.resolve(__dirname,'..');
const OUT=path.resolve(args.out||path.join(ROOT,'preview/Boyang_Chen_AE520_HW3.pdf'));
const HTML=path.resolve(args.html||path.join(fs.mkdtempSync(path.join(os.tmpdir(),'hw3-render-')),'submission.html'));
const esc=s=>s.replaceAll('&','&amp;').replaceAll('<','&lt;').replaceAll('>','&gt;').replaceAll('"','&quot;');
const sha=s=>crypto.createHash('sha256').update(s).digest('hex');
const math=[],blocks=[],sources=[],parts=[];
function addBlock(html){const id=blocks.length;blocks.push(html);return `\n\nBLOCKTOKEN${id}ENDTOKEN\n\n`;}
function addMath(tex,display,source){const id=math.length;const html=katex.renderToString(tex,{displayMode:display,throwOnError:true,strict:'ignore',output:'html'});math.push({id,source,tex,display,sha256:sha(tex)});return display?addBlock(`<div class="math-display" data-math="${id}">${html}</div>`):`MATHINLINETOKEN${id}ENDTOKEN`;}
function readBraced(s,at){if(s[at]!=='{')throw Error('Missing opening brace');let depth=1;for(let j=at+1;j<s.length;j++){if(s[j]==='{'&&s[j-1]!=='\\')depth++;else if(s[j]==='}'&&s[j-1]!=='\\'){depth--;if(!depth)return {text:s.slice(at+1,j),end:j+1};}}throw Error('Unclosed brace in prose');}
function inline(s){
 let out='';
 for(let i=0;i<s.length;){
  const command=s.slice(i).match(/^\\(textbf|textit|emph)\s*/);
  if(command){const start=i+command[0].length;const b=readBraced(s,start);const tag=command[1]==='textbf'?'strong':'em';out+=`<${tag}>${inline(b.text)}</${tag}>`;i=b.end;continue;}
  const token=s.slice(i).match(/^MATHINLINETOKEN(\d+)ENDTOKEN/);
  if(token){const m=math[+token[1]];out+=`<span class="math-inline" data-math="${m.id}">${katex.renderToString(m.tex,{displayMode:false,throwOnError:true,strict:'ignore',output:'html'})}</span>`;i+=token[0].length;continue;}
  if(s.slice(i).startsWith('\\noindent')){i+='\\noindent'.length;continue;}
  if(s.slice(i).startsWith('\\smallskip')){out+=' ';i+='\\smallskip'.length;continue;}
  if(s.slice(i).startsWith('\\%')){out+='%';i+=2;continue;}
  if(s.slice(i).startsWith('\\&')){out+='&amp;';i+=2;continue;}
  if(s.slice(i).startsWith('\\_')){out+='_';i+=2;continue;}
  if(s[i]==='\\')throw Error('Unsupported prose command: '+s.slice(i,i+70));
  if(s[i]==='{'||s[i]==='}')throw Error('Unexpected prose brace: '+s.slice(i,i+50));
  if(s[i]==='~'){out+='&nbsp;';i++;continue;}
  if(s[i]==='\n'){out+=' ';i++;continue;}
  if(s.slice(i).startsWith('--')){out+='-';i+=2;continue;}
  out+=esc(s[i++]);
 }
 return out.trim();
}
function convertProblem(number){
 const file=path.join(ROOT,'solutions',`problem${number}.tex`);const raw=fs.readFileSync(file,'utf8').replace(/^\uFEFF/,'');sources.push({file:path.relative(ROOT,file),sha256:sha(raw)});
 let s=raw.replace(/(?<!\\)%.*$/gm,'');
 const countParts=[...s.matchAll(/\\partlabel\{([^}]+)\}/g)].map(m=>m[1]);parts.push({problem:number,parts:countParts});
 const expected=number<=2?['(a)','(b)','(c)','(d)','(e)','(f)']:number===3?['(a)','(b)','(c)']:['(a)','(b)','(c)','(d)'];
 if(JSON.stringify(countParts)!==JSON.stringify(expected))throw Error('Problem-part coverage mismatch '+number);
 s=s.replace(/\\begin\{(align\*|gather\*)\}[\s\S]*?\\end\{\1\}/g,t=>addMath(t,true,`problem${number}.tex`));
 s=s.replace(/\\\[([\s\S]*?)\\\]/g,(_,t)=>addMath(t,true,`problem${number}.tex`));
 s=s.replace(/(?<!\\)\$([^$]+?)(?<!\\)\$/g,(_,t)=>addMath(t,false,`problem${number}.tex`));
 s=s.replace(/\\begin\{tabular\}\{[^}]+\}([\s\S]*?)\\end\{tabular\}/g,(_,body)=>{
  const rows=body.replace(/\\(?:hline|toprule|midrule|bottomrule)/g,'').split(/\\\\/).map(x=>x.trim()).filter(Boolean).map(row=>row.split('&').map(x=>inline(x.trim())));
  if(rows.length!==5||rows.some(row=>row.length!==5))throw Error('Unexpected Problem 1 result table structure');
  return addBlock('<table><thead><tr>'+rows[0].map(x=>`<th>${x}</th>`).join('')+'</tr></thead><tbody>'+rows.slice(1).map(row=>'<tr>'+row.map(x=>`<td>${x}</td>`).join('')+'</tr>').join('')+'</tbody></table>');
 });
 s=s.replace(/\\includegraphics\[width=([0-9.]+)\\linewidth\]\{([^}]+)\}/g,(_,ratio,target)=>{
  const image=path.resolve(ROOT,target);if(!fs.existsSync(image))throw Error('Missing figure '+image);sources.push({file:target,sha256:sha(fs.readFileSync(image))});
  return addBlock(`<figure><img src="${pathToFileURL(image).href}" style="width:${+ratio*100}%" alt="Three routes from initial state I to sonic states R, F, and S on an h-s diagram."></figure>`);
 });
 s=s.replace(/\\(?:begin|end)\{center\}/g,'\n\n');
 s=s.replace(/\\section\*\{([^}]+)\}/g,(_,title)=>addBlock(`<h2>${inline(title)}</h2>`));
 s=s.replace(/\\partlabel\{([^}]+)\}/g,(_,label)=>addBlock(`<h3>${inline(label)}</h3>`));
 const chunks=s.split(/\n\s*\n/).map(x=>x.trim()).filter(Boolean);
 return `<section class="problem" id="problem-${number}">`+chunks.map(chunk=>{
  const block=chunk.match(/^BLOCKTOKEN(\d+)ENDTOKEN$/);if(block)return blocks[+block[1]];
  if(/BLOCKTOKEN/.test(chunk))throw Error('Block not isolated');
  return `<p>${inline(chunk)}</p>`;
 }).join('\n')+'</section>';
}
const mainPath=path.join(ROOT,'hw3.tex');const main=fs.readFileSync(mainPath,'utf8');sources.push({file:'hw3.tex',sha256:sha(main)});
const meta={};for(const name of ['author','class','date','title']){const m=main.match(new RegExp('\\\\'+name+'\\{([^}]+)\\}'));if(!m)throw Error('Missing title metadata '+name);meta[name]=m[1];}
const ack=main.match(/\{\\small\\textit\{AI assistance:\}([\s\S]*?)\}\s*\\end\{document\}/);if(!ack)throw Error('Missing AI acknowledgment');
const problems=[1,2,3,4].map(convertProblem).join('\n');
const katexRoot=args['katex-dir']?path.resolve(args['katex-dir']):path.dirname(require.resolve('katex/package.json'));
const cssURL=pathToFileURL(path.join(katexRoot,'dist/katex.min.css')).href;
const css=`
@page{size:Letter;margin:0.5in 0.5in 0.55in}
html{font-family:'Times New Roman','Liberation Serif',serif;font-size:11pt;color:#000}
body{margin:0;line-height:1.25}
.title-meta{margin:0;line-height:1.22}.document-title{text-align:center;font-weight:bold;margin:13pt 0 14pt;font-size:11pt}
h2{font-size:11pt;text-align:center;font-variant:small-caps;font-weight:normal;margin:14pt 0 10pt;break-after:avoid;page-break-after:avoid}
h3{font-size:11pt;text-align:left;margin:10pt 0 4pt;font-weight:bold;break-after:avoid;page-break-after:avoid}
p{margin:5pt 0;orphans:3;widows:3}.problem+.problem{break-before:page;page-break-before:always}
.math-display{margin:8pt 0;break-inside:avoid;page-break-inside:avoid;text-align:center}
.math-display .katex-display{margin:0;display:inline-block}.katex{font-size:1em}.math-inline{white-space:normal}
table{border-collapse:collapse;font-size:10pt;margin:10pt auto;width:88%;break-inside:avoid;page-break-inside:avoid}
th{font-weight:normal;border-top:0.6pt solid black;border-bottom:0.4pt solid black}
th,td{padding:3pt 6pt;text-align:right;white-space:nowrap}th:first-child,td:first-child{text-align:left}
tbody tr:last-child td{border-bottom:0.6pt solid black}
figure{margin:7pt 0;break-inside:avoid;page-break-inside:avoid;text-align:center}img{height:auto;max-width:100%}
.ack{font-size:9.5pt;margin-top:16pt;break-inside:avoid}
`;
const html=`<!doctype html><html lang="en"><head><meta charset="utf-8"><title>${esc(meta.title)} - ${esc(meta.author)}</title><link rel="stylesheet" href="${cssURL}"><style>${css}</style></head><body><div class="title-meta">${esc(meta.author)}<br>${esc(meta.class)}<br>${esc(meta.date)}</div><div class="document-title">${esc(meta.title)}</div>${problems}<p class="ack"><em>AI assistance:</em> ${inline(ack[1])}</p></body></html>`;
async function run(){
 fs.mkdirSync(path.dirname(OUT),{recursive:true});fs.mkdirSync(path.dirname(HTML),{recursive:true});fs.writeFileSync(HTML,html);
 const browser=await chromium.launch({headless:true,...(args.chrome?{executablePath:args.chrome}:{}),args:['--disable-gpu','--no-first-run']});
 try{
  const page=await browser.newPage({viewport:{width:720,height:950}});await page.goto(pathToFileURL(HTML).href,{waitUntil:'load'});await page.evaluate(()=>document.fonts.ready);await page.emulateMedia({media:'print'});
  const audit=await page.evaluate(()=>{
   const resized=[];
   for(const item of document.querySelectorAll('.math-display')){
    const math=item.querySelector('.katex-display');const width=math.getBoundingClientRect().width;const available=item.clientWidth-2;
    if(width>available){const ratio=available/width;item.style.fontSize=(parseFloat(getComputedStyle(item).fontSize)*ratio)+'px';resized.push({id:item.dataset.math,ratio,fontPt:11*ratio});}
   }
   for(const p of document.querySelectorAll('p')){if(p.nextElementSibling?.matches('.math-display,table'))p.style.breakAfter='avoid';if(p.children.length===1&&p.firstElementChild.tagName==='STRONG')p.style.breakAfter='avoid';}
   const missingImages=[...document.images].filter(i=>!i.complete||i.naturalWidth===0).map(i=>i.src);
   const bounds=document.body.getBoundingClientRect();
   const overflow=[...document.querySelectorAll('.math-display,.katex-display,table,p,img')].filter(e=>e.getBoundingClientRect().right>bounds.right+2||e.getBoundingClientRect().left<bounds.left-2).map(e=>({tag:e.tagName,math:e.dataset.math,text:e.innerText?.slice(0,80)}));
   const rawTokens=/MATHINLINETOKEN|BLOCKTOKEN/.test(document.body.innerText);
   return {resized,missingImages,overflow,rawTokens,problemHeadings:[...document.querySelectorAll('h2')].map(e=>e.textContent),partLabels:[...document.querySelectorAll('h3')].map(e=>e.textContent),textLength:document.body.innerText.length};
  });
  if(audit.missingImages.length||audit.overflow.length||audit.rawTokens)throw Error(JSON.stringify(audit));
  await page.pdf({path:OUT,format:'Letter',printBackground:true,preferCSSPageSize:true,displayHeaderFooter:true,outline:true,headerTemplate:'<div></div>',footerTemplate:'<div style="font-family:Times New Roman;font-size:9px;width:100%;text-align:center;color:black"><span class="pageNumber"></span></div>'});
  const report={renderer:'Literal LaTeX mathematics rendered by KaTeX, HTML paginated by Chromium; not LaTeX compiled.',metadata:meta,sourceFiles:sources,mathCount:math.length,math,parts,...audit,output:OUT};
  if(args.audit)fs.writeFileSync(path.resolve(args.audit),JSON.stringify(report,null,2));
  console.log(JSON.stringify({output:OUT,mathCount:math.length,parts,...audit},null,2));
 }finally{await browser.close();}
}
run().catch(e=>{console.error(e);process.exit(1)});
