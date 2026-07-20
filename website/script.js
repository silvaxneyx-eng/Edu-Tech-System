document.addEventListener('DOMContentLoaded', () => {
    // 1. Botão de Copiar
    const copyBtn = document.getElementById('copyCmd');
    if (copyBtn) {
        copyBtn.addEventListener('click', async () => {
            const cmdText = "curl -sSL https://raw.githubusercontent.com/silvaxneyx-eng/Edu-Tech-System/main/install.sh | bash";
            try {
                await navigator.clipboard.writeText(cmdText);
                const icon = copyBtn.querySelector('i');
                icon.classList.remove('ph-copy');
                icon.classList.add('ph-check');
                copyBtn.style.color = 'var(--secondary-color)';
                setTimeout(() => {
                    icon.classList.remove('ph-check');
                    icon.classList.add('ph-copy');
                    copyBtn.style.color = '';
                }, 2000);
            } catch (err) {
                console.error('Falha ao copiar:', err);
            }
        });
    }

    // 2. Efeito Mouse "Glow" (Pique Google/Vercel)
    const cursorGlow = document.createElement('div');
    cursorGlow.classList.add('cursor-glow');
    document.body.appendChild(cursorGlow);

    document.addEventListener('mousemove', (e) => {
        // Usa requestAnimationFrame para performance absurda
        requestAnimationFrame(() => {
            cursorGlow.style.left = e.clientX + 'px';
            cursorGlow.style.top = e.clientY + 'px';
        });
    });

    // Efeito magnético nos botões
    const buttons = document.querySelectorAll('.btn-primary, .btn-secondary, .btn-primary-outline');
    buttons.forEach(btn => {
        btn.addEventListener('mousemove', (e) => {
            const rect = btn.getBoundingClientRect();
            const x = e.clientX - rect.left - rect.width / 2;
            const y = e.clientY - rect.top - rect.height / 2;
            btn.style.transform = `translate(${x * 0.2}px, ${y * 0.2}px) scale(1.05)`;
        });
        btn.addEventListener('mouseleave', () => {
            btn.style.transform = 'translate(0px, 0px) scale(1)';
        });
    });

    // 3. Animação de Texto Letra por Letra (Span splitting)
    const heroTitle = document.querySelector('.hero-title span');
    if (heroTitle) {
        const text = heroTitle.textContent;
        heroTitle.textContent = '';
        text.split('').forEach((char, index) => {
            const span = document.createElement('span');
            span.textContent = char === ' ' ? '\u00A0' : char;
            span.classList.add('animate-char');
            span.style.animationDelay = `${index * 0.05}s`;
            heroTitle.appendChild(span);
        });
    }

    // 4. Efeito 3D Tilt nos Cards
    const cards = document.querySelectorAll('.feature-card');
    cards.forEach(card => {
        card.addEventListener('mousemove', (e) => {
            const rect = card.getBoundingClientRect();
            const x = e.clientX - rect.left;
            const y = e.clientY - rect.top;
            
            const centerX = rect.width / 2;
            const centerY = rect.height / 2;
            
            const rotateX = ((y - centerY) / centerY) * -10; // Invertido para efeito realista
            const rotateY = ((x - centerX) / centerX) * 10;
            
            card.style.transform = `perspective(1000px) rotateX(${rotateX}deg) rotateY(${rotateY}deg) scale3d(1.02, 1.02, 1.02)`;
        });
        
        card.addEventListener('mouseleave', () => {
            card.style.transform = 'perspective(1000px) rotateX(0) rotateY(0) scale3d(1, 1, 1)';
        });
    });
});
