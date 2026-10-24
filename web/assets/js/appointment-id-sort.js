(function () {
    'use strict';

    document.querySelectorAll('[data-appointment-id-sort]').forEach(function (header) {
        var button = header.querySelector('button');
        var body = header.closest('table').tBodies[0];
        var icon = button.querySelector('i');
        var storageKey = 'appointment-id-sort:' + window.location.pathname;
        var direction = null;

        function sortRows(nextDirection) {
            var rows = Array.from(body.querySelectorAll('tr[data-appointment-id]'));
            rows.sort(function (a, b) {
                var difference = Number(a.dataset.appointmentId) - Number(b.dataset.appointmentId);
                return nextDirection === 'ascending' ? difference : -difference;
            });
            rows.forEach(function (row) {
                body.appendChild(row);
            });
            direction = nextDirection;
            header.setAttribute('aria-sort', direction);
            icon.className = direction === 'ascending' ? 'bi bi-arrow-up' : 'bi bi-arrow-down';
        }

        // Keep the chosen order when the waiting list refreshes automatically.
        try {
            var savedDirection = window.sessionStorage.getItem(storageKey);
            if (savedDirection === 'ascending' || savedDirection === 'descending') {
                sortRows(savedDirection);
            }
        } catch (error) {
            // Sorting still works when browser storage is unavailable.
        }

        button.addEventListener('click', function () {
            sortRows(direction === 'ascending' ? 'descending' : 'ascending');
            try {
                window.sessionStorage.setItem(storageKey, direction);
            } catch (error) {
                // Saving the preference is optional.
            }
        });
    });
}());
