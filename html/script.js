const app = document.getElementById('app');
const animationList = document.getElementById('animation-list');
const radioStatus = document.getElementById('radio-status');
const radioDot = document.getElementById('radio-dot');
const statusRadio = document.getElementById('status-radio');
const activeEmote = document.getElementById('active-emote');
const btnClose = document.getElementById('btn-close');

const ICONS = {
    'fa-solid fa-wave-square': `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"><path d="M2 12h2"/><path d="M6 8v8"/><path d="M10 5v14"/><path d="M14 8v8"/><path d="M18 5v14"/><path d="M22 12h-2"/></svg>`,
    'fa-solid fa-user': `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="7" r="3.5"/><path d="M5.5 20c.6-3.2 3-5.5 6.5-5.5s6 2.3 6.5 5.5"/></svg>`,
    'fa-solid fa-walkie-talkie': `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"><rect x="7" y="3" width="10" height="18" rx="2"/><circle cx="12" cy="17" r="1" fill="currentColor" stroke="none"/><path d="M10 7h4"/><path d="M9 11h1.8a1.2 1.2 0 0 1 0 2.4H9"/></svg>`,
    'fa-solid fa-headset': `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"><path d="M4 14v-2a8 8 0 0 1 16 0v2"/><rect x="2" y="14" width="5" height="7" rx="2"/><rect x="17" y="14" width="5" height="7" rx="2"/></svg>`,
    'fa-solid fa-radio': `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="17" r="1.5" fill="currentColor" stroke="none"/><path d="M16.5 8.5a7 7 0 0 0-9 0"/><path d="M19.5 5.5a11 11 0 0 0-15 0"/><path d="M6 17h12a2 2 0 0 0 2-2v-1a2 2 0 0 0-2-2H6a2 2 0 0 0-2 2v1a2 2 0 0 0 2 2z"/></svg>`,
    'fa-solid fa-microphone': `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="2" width="6" height="11" rx="3"/><path d="M5 10a7 7 0 0 0 14 0"/><path d="M12 17v5"/></svg>`,
    'wave': `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"><path d="M2 12h2"/><path d="M6 8v8"/><path d="M10 5v14"/><path d="M14 8v8"/><path d="M18 5v14"/><path d="M22 12h-2"/></svg>`,
    'user': `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="7" r="3.5"/><path d="M5.5 20c.6-3.2 3-5.5 6.5-5.5s6 2.3 6.5 5.5"/></svg>`,
    'radio': `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"><rect x="7" y="3" width="10" height="18" rx="2"/><circle cx="12" cy="17" r="1" fill="currentColor" stroke="none"/><path d="M10 7h4"/><path d="M9 11h1.8a1.2 1.2 0 0 1 0 2.4H9"/></svg>`,
    'headset': `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"><path d="M4 14v-2a8 8 0 0 1 16 0v2"/><rect x="2" y="14" width="5" height="7" rx="2"/><rect x="17" y="14" width="5" height="7" rx="2"/></svg>`,
};

const CHECK_ICON = `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12l4 4L19 6"/></svg>`;

let state = {
    selectedEmote: null,
    radioActive: false,
    animations: [],
};

function getIcon(iconKey) {
    return ICONS[iconKey] || ICONS['fa-solid fa-radio'];
}

function getEmoteTitle(emote) {
    const entry = state.animations.find((a) => a.emote === emote);
    return entry ? (entry.title || emote) : (emote || '—');
}

function postNui(event, data = {}) {
    fetch(`https://${GetParentResourceName()}/${event}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data),
    });
}

function closeUI() {
    app.classList.add('hidden');
    postNui('close');
}

function updateStatus() {
    radioStatus.textContent = state.radioActive ? 'Aktiv' : 'Inaktiv';
    statusRadio.classList.toggle('active', state.radioActive);
    activeEmote.textContent = getEmoteTitle(state.selectedEmote);
}

function updateSelection() {
    const cards = animationList.querySelectorAll('.animation-card');
    cards.forEach((card) => {
        const emote = card.dataset.emote;
        const isSelected = emote === state.selectedEmote;
        card.classList.toggle('selected', isSelected);
        const check = card.querySelector('.card-check');
        if (check) check.innerHTML = isSelected ? CHECK_ICON : '';
    });
    updateStatus();
}

function renderAnimations(animations, animate) {
    animationList.innerHTML = '';
    animationList.classList.toggle('initial-open', !!animate);

    animations.forEach((entry, index) => {
        const card = document.createElement('div');
        const isSelected = entry.emote === state.selectedEmote;
        card.className = 'animation-card' + (isSelected ? ' selected' : '');
        card.dataset.emote = entry.emote;
        if (animate) card.style.animationDelay = `${index * 0.04}s`;

        card.innerHTML = `
            <div class="card-icon">${getIcon(entry.icon)}</div>
            <div class="card-content">
                <div class="card-title">${entry.title || entry.emote}</div>
                <div class="card-desc">${entry.description || ''}</div>
            </div>
            <div class="card-check">${isSelected ? CHECK_ICON : ''}</div>
        `;

        card.addEventListener('click', () => {
            if (state.selectedEmote === entry.emote) return;
            state.selectedEmote = entry.emote;
            postNui('selectAnimation', { emote: entry.emote, title: entry.title });
            updateSelection();
        });

        animationList.appendChild(card);
    });
}

function openUI(data) {
    state.selectedEmote = data.selectedEmote;
    state.radioActive = data.radioActive;
    state.animations = data.animations || [];
    renderAnimations(state.animations, true);
    updateStatus();
    app.classList.remove('hidden');
}

window.addEventListener('message', (event) => {
    const data = event.data;
    if (!data || !data.action) return;

    if (data.action === 'open') {
        openUI(data);
    } else if (data.action === 'close') {
        app.classList.add('hidden');
    } else if (data.action === 'updateStatus') {
        state.radioActive = data.radioActive;
        state.selectedEmote = data.selectedEmote;
        updateStatus();
    }
});

btnClose.addEventListener('click', closeUI);

document.addEventListener('keydown', (event) => {
    if (event.key === 'Escape' && !app.classList.contains('hidden')) {
        closeUI();
    }
});
