// Uyoop smart form logic
(function(){
  const form = document.getElementById('need-form');
  const projectType = document.getElementById('project_type');
  const conditional = document.getElementById('conditional-sections');
  const previewBtn = document.getElementById('preview-btn');
  const preview = document.getElementById('preview');
  const previewContent = document.getElementById('preview-content');
  const downloadLink = document.getElementById('download-link');

  const templates = {
    audit: () => `
      <div class="grid">
        <label class="field full">
          <span>Périmètre à auditer</span>
          <textarea name="audit_scope" rows="3" placeholder="SI, site web, production, sécurité, RGPD…"></textarea>
        </label>
        <label class="field">
          <span>Maturité numérique</span>
          <select name="digital_maturity">
            <option value="low">Faible</option>
            <option value="medium">Moyenne</option>
            <option value="high">Élevée</option>
          </select>
        </label>
        <label class="field">
          <span>Risques identifiés</span>
          <textarea name="risks" rows="3" placeholder="Disponibilité, sécurité, conformité…"></textarea>
        </label>
      </div>
    `,
    website: () => `
      <div class="grid">
        <label class="field">
          <span>Type de site</span>
          <select name="site_type">
            <option value="corporate">Corporate</option>
            <option value="ecommerce">E-commerce</option>
            <option value="landing">Landing Page</option>
            <option value="blog">Blog / Média</option>
          </select>
        </label>
        <label class="field">
          <span>Pages clés</span>
          <input type="text" name="key_pages" placeholder="Accueil, À propos, Services, Contact…" />
        </label>
        <label class="field">
          <span>CMS préféré</span>
          <select name="cms">
            <option value="none">Aucun / Sur-mesure</option>
            <option value="wordpress">WordPress</option>
            <option value="strapi">Strapi</option>
            <option value="drupal">Drupal</option>
          </select>
        </label>
        <label class="field">
          <span>Fonctionnalités</span>
          <textarea name="features" rows="3" placeholder="Formulaire, newsletter, multilingue, SEO…"></textarea>
        </label>
      </div>
    `,
    app: () => `
      <div class="grid">
        <label class="field">
          <span>Plateforme</span>
          <select name="platform">
            <option value="web">Web</option>
            <option value="mobile">Mobile (iOS/Android)</option>
            <option value="both">Web + Mobile</option>
          </select>
        </label>
        <label class="field">
          <span>Modules</span>
          <textarea name="modules" rows="3" placeholder="Auth, profils, paiement, notifications…"></textarea>
        </label>
        <label class="field">
          <span>Intégrations</span>
          <textarea name="integrations" rows="3" placeholder="API externes, ERP, CRM…"></textarea>
        </label>
      </div>
    `,
    devops: () => `
      <div class="grid">
        <label class="field">
          <span>Environnement cible</span>
          <select name="env">
            <option value="cloud">Cloud</option>
            <option value="onprem">On-premise</option>
            <option value="hybrid">Hybride</option>
          </select>
        </label>
        <label class="field">
          <span>CI/CD</span>
          <textarea name="cicd" rows="3" placeholder="Build, tests, déploiement, GitOps…"></textarea>
        </label>
        <label class="field">
          <span>Sécurité & conformité</span>
          <textarea name="security" rows="3" placeholder="Secrets, IAM, sauvegardes, audit…"></textarea>
        </label>
      </div>
    `
  };

  function renderConditional(type){
    conditional.innerHTML = templates[type] ? templates[type]() : '';
  }

  function formDataToObject(fd){
    const obj = {};
    for (const [k,v] of fd.entries()) {
      obj[k] = v;
    }
    return obj;
  }

  function buildSpecHTML(data){
    const sections = [];
    sections.push(`<h3>Informations générales</h3>`);
    sections.push(`<ul>
      <li><strong>Organisation:</strong> ${data.org_name||''}</li>
      <li><strong>Contact:</strong> ${data.contact_name||''} (${data.contact_email||''})</li>
      <li><strong>Type de projet:</strong> ${data.project_type||''}</li>
    </ul>`);

    sections.push(`<h3>Objectifs & contraintes</h3>`);
    sections.push(`<ul>
      <li><strong>Budget:</strong> ${data.budget||'N/A'} €</li>
      <li><strong>Délais:</strong> ${data.timeline||'N/A'}</li>
      <li><strong>Objectifs:</strong> ${data.goals||''}</li>
    </ul>`);

    // Project-type specific summary
    if (data.project_type === 'audit') {
      sections.push(`<h3>Audit</h3>`);
      sections.push(`<ul>
        <li><strong>Périmètre:</strong> ${data.audit_scope||''}</li>
        <li><strong>Maturité:</strong> ${data.digital_maturity||''}</li>
        <li><strong>Risques:</strong> ${data.risks||''}</li>
      </ul>`);
    }
    if (data.project_type === 'website') {
      sections.push(`<h3>Site web</h3>`);
      sections.push(`<ul>
        <li><strong>Type:</strong> ${data.site_type||''}</li>
        <li><strong>Pages clés:</strong> ${data.key_pages||''}</li>
        <li><strong>CMS:</strong> ${data.cms||''}</li>
        <li><strong>Fonctionnalités:</strong> ${data.features||''}</li>
      </ul>`);
    }
    if (data.project_type === 'app') {
      sections.push(`<h3>Application</h3>`);
      sections.push(`<ul>
        <li><strong>Plateforme:</strong> ${data.platform||''}</li>
        <li><strong>Modules:</strong> ${data.modules||''}</li>
        <li><strong>Intégrations:</strong> ${data.integrations||''}</li>
      </ul>`);
    }
    if (data.project_type === 'devops') {
      sections.push(`<h3>DEVOPS / Infra</h3>`);
      sections.push(`<ul>
        <li><strong>Environnement:</strong> ${data.env||''}</li>
        <li><strong>CI/CD:</strong> ${data.cicd||''}</li>
        <li><strong>Sécurité:</strong> ${data.security||''}</li>
      </ul>`);
    }

    const html = `
      <article>
        <h2>Cahier des charges — ${data.org_name||'Projet'}</h2>
        ${sections.join('\n')}
      </article>
    `;
    return html;
  }

  projectType.addEventListener('change', (e)=>{
    renderConditional(e.target.value);
  });

  previewBtn.addEventListener('click', ()=>{
    const fd = new FormData(form);
    const data = formDataToObject(fd);
    const html = buildSpecHTML(data);
    previewContent.innerHTML = html;
    preview.hidden = false;
  });

  form.addEventListener('submit', async (e)=>{
    e.preventDefault();
    const fd = new FormData(form);
    const data = Object.fromEntries(fd.entries());

    try {
      const res = await fetch('/api/save', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
      });
      const ok = res.ok;
      const payload = await res.json().catch(()=>({}));
      const id = payload && payload.id ? payload.id : undefined;
      const html = buildSpecHTML(data);
      previewContent.innerHTML = html;
      preview.hidden = false;
      if (ok && id) {
        downloadLink.href = `/generate?id=${encodeURIComponent(id)}`;
        alert(payload.message || 'Enregistrement réussi.');
      } else {
        downloadLink.href = `/generate`;
        alert('Enregistrement non disponible.');
      }
    } catch(err) {
      console.error(err);
      alert('Erreur réseau.');
    }
  });
})();
