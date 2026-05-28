const app = document.getElementById('app');
const floorsList = document.getElementById('floors-list');
const currentFloorDisplay = document.getElementById('current-floor');
const arrowUp = document.getElementById('arrow-up');
const arrowDown = document.getElementById('arrow-down');


window.addEventListener('message', function(event) {
    const data = event.data;

    if (data.action === 'open') {
        app.style.display = 'flex';
        setupElevator(data.floors, data.currentFloor);
    } else if (data.action === 'close') {
        app.style.display = 'none';
    }
});

function setupElevator(floors, currentFloorIndex) {
    floorsList.innerHTML = '';
    
    // Affichage de l'étage actuel (utilise le numéro logique s'il existe)
    if (floors[currentFloorIndex - 1] && floors[currentFloorIndex - 1].floorNumber !== undefined) {
        currentFloorDisplay.innerText = floors[currentFloorIndex - 1].floorNumber;
    } else {
        currentFloorDisplay.innerText = currentFloorIndex - 1;
    }
    
    // Reset arrows
    arrowUp.classList.remove('active');
    arrowDown.classList.remove('active');

    floors.forEach((floor, index) => {
        const btn = document.createElement('div');
        btn.className = 'floor-btn';
        
        // Marquer l'étage actuel
        if (index + 1 === currentFloorIndex) {
            btn.classList.add('current');
        }

        // Contenu du bouton
        const displayNum = floor.floorNumber !== undefined ? floor.floorNumber : index;
        btn.innerHTML = `
            <span class="floor-number">${displayNum}</span>
            <span class="floor-name">${floor.label || 'Étage ' + displayNum}</span>
        `;

        btn.onclick = () => {
            if (index + 1 === currentFloorIndex) return; // Déjà à cet étage

            // Animation visuelle
            btn.classList.add('active-press');
            
            // Animation flèches
            const currentFloorObj = floors[currentFloorIndex - 1];
            const targetFloorObj = floor;

            if (targetFloorObj.coords.z > currentFloorObj.coords.z) {
                arrowUp.classList.add('active');
            } else {
                arrowDown.classList.add('active');
            }

            // Envoyer au client
            fetch(`https://${GetParentResourceName()}/travel`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json; charset=UTF-8',
                },
                body: JSON.stringify({
                    floorIndex: index + 1
                })
            });

            // Fermer après un court délai pour voir l'animation
            setTimeout(() => {
                app.style.display = 'none';
                btn.classList.remove('active-press');
            }, 300);
        };

        floorsList.appendChild(btn);
    });
}

document.onkeyup = function(data) {
    if (data.key === "Escape") {
        fetch(`https://${GetParentResourceName()}/close`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({})
        });
        app.style.display = 'none';
    }
};
