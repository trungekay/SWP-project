<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:include page="/views/admin/layout/admin-css.jsp" />
<style>
    /* Custom enhancements for Employee & Staff Portal */
    :root {
        --vc-teal: #008b74;
        --vc-teal-dark: #00705d;
        --vc-teal-light: #e6f7f4;
        --vc-bg: #f4f7f9;
        --vc-card-bg: #ffffff;
    }

    body {
        background-color: var(--vc-bg);
        font-family: 'Inter', -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    }

    /* KPI / Metric cards */
    .metric-card {
        background: #ffffff;
        border-radius: 14px;
        padding: 20px 24px;
        border: 1px solid rgba(0,0,0,0.04);
        box-shadow: 0 2px 12px rgba(15, 23, 42, 0.04);
        display: flex;
        align-items: center;
        gap: 18px;
        height: 100%;
        min-height: 94px;
        transition: transform 0.2s ease, box-shadow 0.2s ease;
    }
    .metric-card:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 18px rgba(15, 23, 42, 0.07);
    }
    .metric-icon-box {
        width: 52px;
        height: 52px;
        border-radius: 12px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 24px;
        flex-shrink: 0;
    }
    .metric-icon-teal { background: #e0f2fe; color: #0284c7; }
    .metric-icon-warning { background: #fef3c7; color: #d97706; }
    .metric-icon-success { background: #dcfce7; color: #16a34a; }
    .metric-icon-purple { background: #f3e8ff; color: #9333ea; }
    .metric-icon-danger { background: #fee2e2; color: #dc2626; }

    .metric-info {
        flex: 1;
        min-width: 0;
        display: flex;
        flex-direction: column;
        justify-content: center;
    }
    .metric-info .metric-num {
        font-size: 26px;
        font-weight: 700;
        color: #0f172a;
        line-height: 1.2;
    }
    .metric-info .metric-title {
        font-size: 13.5px;
        font-weight: 500;
        color: #64748b;
        margin-bottom: 0;
        line-height: 1.35;
        min-height: 38px;
        display: flex;
        align-items: center;
    }

    /* Content card */
    .content-card {
        background: #ffffff;
        border-radius: 14px;
        border: 1px solid rgba(0,0,0,0.05);
        box-shadow: 0 2px 14px rgba(15, 23, 42, 0.04);
        overflow: hidden;
        margin-bottom: 24px;
    }

    /* Table Toolbar */
    .table-toolbar {
        padding: 16px 24px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        flex-wrap: wrap;
        gap: 14px;
        border-bottom: 1px solid #f1f5f9;
        background: #ffffff;
    }

    /* Pulse indicator for live queue */
    .pulse-indicator {
        width: 10px;
        height: 10px;
        border-radius: 50%;
        background-color: #22c55e;
        display: inline-block;
        box-shadow: 0 0 0 0 rgba(34, 197, 94, 0.7);
        animation: pulse-green 2s infinite;
        flex-shrink: 0;
    }
    @keyframes pulse-green {
        0% {
            transform: scale(0.95);
            box-shadow: 0 0 0 0 rgba(34, 197, 94, 0.7);
        }
        70% {
            transform: scale(1);
            box-shadow: 0 0 0 6px rgba(34, 197, 94, 0);
        }
        100% {
            transform: scale(0.95);
            box-shadow: 0 0 0 0 rgba(34, 197, 94, 0);
        }
    }

    .search-filter-input {
        position: relative;
        min-width: 260px;
    }
    .search-filter-input input {
        width: 100%;
        height: 38px;
        padding: 8px 16px 8px 38px;
        border: 1px solid #e2e8f0;
        border-radius: 8px;
        font-size: 14px;
        background-color: #f8fafc;
        transition: all 0.2s;
    }
    .search-filter-input input:focus {
        background-color: #ffffff;
        border-color: var(--primary-color);
        box-shadow: 0 0 0 3px rgba(0, 139, 116, 0.12);
        outline: none;
    }
    .search-filter-input i {
        position: absolute;
        left: 12px;
        top: 50%;
        transform: translateY(-50%);
        color: #94a3b8;
    }

    .form-select-custom {
        height: 38px;
        padding: 6px 30px 6px 12px;
        border: 1px solid #e2e8f0;
        border-radius: 8px;
        font-size: 13.5px;
        color: #334155;
        background-color: #f8fafc;
        outline: none;
        cursor: pointer;
        transition: all 0.2s;
    }
    .form-select-custom:focus {
        border-color: var(--primary-color);
        background-color: #ffffff;
        box-shadow: 0 0 0 3px rgba(0, 139, 116, 0.12);
    }

    /* Buttons */
    .btn-teal {
        background-color: var(--primary-color);
        color: #ffffff;
        border: none;
        padding: 9px 18px;
        border-radius: 8px;
        font-size: 14px;
        font-weight: 500;
        display: inline-flex;
        align-items: center;
        gap: 8px;
        transition: all 0.2s;
        text-decoration: none;
    }
    .btn-teal:hover {
        background-color: var(--primary-hover);
        color: #ffffff;
        box-shadow: 0 4px 12px rgba(0, 139, 116, 0.25);
    }
    .btn-teal-outline {
        background-color: transparent;
        color: var(--primary-color);
        border: 1.5px solid var(--primary-color);
        padding: 7px 14px;
        border-radius: 8px;
        font-size: 13.5px;
        font-weight: 500;
        display: inline-flex;
        align-items: center;
        gap: 6px;
        transition: all 0.2s;
        text-decoration: none;
    }
    .btn-teal-outline:hover {
        background-color: #f0fdfa;
        color: var(--primary-hover);
        border-color: var(--primary-hover);
    }

    /* Custom Table */
    .table-container {
        overflow-x: auto;
    }
    .custom-table {
        width: 100%;
        margin: 0;
        border-collapse: collapse;
    }
    .custom-table th {
        background-color: #f8fafc;
        color: #64748b;
        font-size: 12px;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        padding: 12px 14px;
        border-bottom: 1px solid #e2e8f0;
        white-space: nowrap;
        vertical-align: middle;
    }
    .custom-table td {
        padding: 12px 14px;
        vertical-align: middle;
        border-bottom: 1px solid #f1f5f9;
        font-size: 13.5px;
        color: #334155;
    }
    .custom-table tbody tr {
        transition: background-color 0.15s ease;
    }
    .custom-table tbody tr:hover {
        background-color: #f8fafc;
    }

    /* Action Buttons (Exact User Management style) */
    .action-btns {
        display: inline-flex;
        gap: 6px;
        align-items: center;
        justify-content: center;
    }
    .action-btn,
    .custom-table .btn-sm,
    .table-custom .btn-sm {
        width: 32px;
        height: 32px;
        min-width: 32px;
        min-height: 32px;
        padding: 0;
        font-size: 13.5px;
        border-radius: 6px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        text-decoration: none;
        border: 1px solid transparent;
        transition: all 0.18s ease;
        cursor: pointer;
        line-height: 1;
    }
    .action-btn:hover,
    .custom-table .btn-sm:hover,
    .table-custom .btn-sm:hover {
        transform: translateY(-2px);
    }

    /* 1. Primary / Edit / View (Green soft pastel like user-list) */
    .action-btn:not(.checkin):not(.warning):not(.delete):not(.success):not(.complete):not([disabled]),
    .custom-table .btn-outline-primary,
    .table-custom .btn-outline-primary {
        color: #18a05e !important;
        border-color: #bbf7d0 !important;
        background-color: #f0fdf4 !important;
    }
    .action-btn:not(.checkin):not(.warning):not(.delete):not(.success):not(.complete):not([disabled]):hover,
    .custom-table .btn-outline-primary:hover,
    .table-custom .btn-outline-primary:hover {
        background-color: #18a05e !important;
        border-color: #18a05e !important;
        color: #ffffff !important;
        box-shadow: 0 2px 6px rgba(24, 160, 94, 0.25) !important;
    }

    /* 2. Success / Check-in / Start / Complete (Brand Green) */
    .action-btn.checkin,
    .action-btn.complete,
    .action-btn.success,
    .custom-table .btn-outline-success,
    .table-custom .btn-outline-success {
        color: #16a34a !important;
        border-color: #bbf7d0 !important;
        background-color: #f0fdf4 !important;
    }
    .action-btn.checkin:hover,
    .action-btn.complete:hover,
    .action-btn.success:hover,
    .custom-table .btn-outline-success:hover,
    .table-custom .btn-outline-success:hover {
        background-color: #16a34a !important;
        border-color: #16a34a !important;
        color: #ffffff !important;
        box-shadow: 0 2px 6px rgba(22, 163, 74, 0.25) !important;
    }

    /* 3. Warning / Skip / Lock (Amber / Yellow) */
    .action-btn.warning,
    .custom-table .btn-outline-warning,
    .table-custom .btn-outline-warning {
        color: #d97706 !important;
        border-color: #fde68a !important;
        background-color: #fffbeb !important;
    }
    .action-btn.warning:hover,
    .custom-table .btn-outline-warning:hover,
    .table-custom .btn-outline-warning:hover {
        background-color: #d97706 !important;
        border-color: #d97706 !important;
        color: #ffffff !important;
        box-shadow: 0 2px 6px rgba(217, 119, 6, 0.25) !important;
    }

    /* 4. Danger / Delete / Cancel / Absent (Red / Coral) */
    .action-btn.delete,
    .action-btn.danger,
    .custom-table .btn-outline-danger,
    .table-custom .btn-outline-danger {
        color: #dc2626 !important;
        border-color: #fecaca !important;
        background-color: #fef2f2 !important;
    }
    .action-btn.delete:hover,
    .action-btn.danger:hover,
    .custom-table .btn-outline-danger:hover,
    .table-custom .btn-outline-danger:hover {
        background-color: #dc2626 !important;
        border-color: #dc2626 !important;
        color: #ffffff !important;
        box-shadow: 0 2px 6px rgba(220, 38, 38, 0.25) !important;
    }

    /* 5. Disabled / Busy doctor */
    .action-btn[disabled],
    .custom-table .btn-sm[disabled] {
        opacity: 0.45 !important;
        cursor: not-allowed !important;
        transform: none !important;
        box-shadow: none !important;
        background-color: #f8fafc !important;
        border-color: #e2e8f0 !important;
        color: #94a3b8 !important;
    }

    /* Table Action Buttons */
    .btn-action-checkin {
        background-color: #008b74;
        color: #ffffff;
        border: none;
        padding: 6px 12px;
        border-radius: 6px;
        font-size: 12.5px;
        font-weight: 600;
        display: inline-flex;
        align-items: center;
        gap: 5px;
        transition: all 0.2s ease;
        text-decoration: none;
        line-height: 1.35;
        box-shadow: 0 1px 3px rgba(0, 139, 116, 0.25);
    }
    .btn-action-checkin:hover {
        background-color: #00705d;
        color: #ffffff;
        box-shadow: 0 2px 6px rgba(0, 139, 116, 0.35);
        transform: translateY(-1px);
    }
    .btn-action-view {
        background-color: #f8fafc;
        color: #475569;
        border: 1px solid #cbd5e1;
        padding: 6px 10px;
        border-radius: 6px;
        font-size: 13px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        transition: all 0.2s ease;
        text-decoration: none;
        line-height: 1.35;
    }
    .btn-action-view:hover {
        background-color: #e2e8f0;
        color: #0f172a;
        border-color: #94a3b8;
    }
    .btn-action-cancel {
        background-color: #fff1f2;
        color: #e11d48;
        border: 1px solid #fecdd3;
        padding: 6px 11px;
        border-radius: 6px;
        font-size: 12.5px;
        font-weight: 600;
        display: inline-flex;
        align-items: center;
        gap: 5px;
        transition: all 0.2s ease;
        text-decoration: none;
        line-height: 1.35;
    }
    .btn-action-cancel:hover {
        background-color: #e11d48;
        color: #ffffff;
        border-color: #e11d48;
        box-shadow: 0 2px 6px rgba(225, 29, 72, 0.25);
        transform: translateY(-1px);
    }
    .btn-action-queue {
        background-color: #f0fdfa;
        color: #0d9488;
        border: 1px solid #0d9488;
        padding: 6px 10px;
        border-radius: 6px;
        font-size: 12px;
        font-weight: 600;
        display: inline-flex;
        align-items: center;
        gap: 4px;
        transition: all 0.2s ease;
        text-decoration: none;
        line-height: 1.35;
    }
    .btn-action-queue:hover {
        background-color: #0d9488;
        color: #ffffff;
    }

    /* Badges - Unified Clinic Status System */
    .badge-status {
        padding: 5px 12px;
        border-radius: 20px;
        font-size: 12.5px;
        font-weight: 600;
        display: inline-flex;
        align-items: center;
        gap: 6px;
        white-space: nowrap;
        line-height: 1.4;
    }
    .badge-status::before {
        content: "";
        width: 6px;
        height: 6px;
        border-radius: 50%;
        display: inline-block;
        flex-shrink: 0;
    }
    .badge-pending {
        background-color: #fef3c7;
        color: #b45309;
        border: 1px solid #fde68a;
    }
    .badge-pending::before { background-color: #f59e0b; }

    .badge-confirmed {
        background-color: #e0f2fe;
        color: #0369a1;
        border: 1px solid #bae6fd;
    }
    .badge-confirmed::before { background-color: #0ea5e9; }

    .badge-in-progress {
        background-color: #ede9fe;
        color: #6d28d9;
        border: 1px solid #ddd6fe;
    }
    .badge-in-progress::before { background-color: #8b5cf6; }

    .badge-completed {
        background-color: #dcfce7;
        color: #15803d;
        border: 1px solid #bbf7d0;
    }
    .badge-completed::before { background-color: #16a34a; }

    .badge-canceled {
        background-color: #fee2e2;
        color: #b91c1c;
        border: 1px solid #fecaca;
    }
    .badge-canceled::before { background-color: #ef4444; }

    /* Queue badge */
    .queue-badge {
        width: 38px;
        height: 38px;
        border-radius: 10px;
        background: linear-gradient(135deg, #0d9488, #008b74);
        color: #ffffff;
        font-weight: 700;
        font-size: 15px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        box-shadow: 0 2px 6px rgba(13, 148, 136, 0.25);
    }
    .queue-badge.queue-badge-active {
        background: linear-gradient(135deg, #6366f1, #4f46e5);
        box-shadow: 0 2px 8px rgba(99, 102, 241, 0.35);
    }
    .custom-table tbody tr.row-examining {
        background-color: #faf5ff;
    }
    .custom-table tbody tr.row-examining:hover {
        background-color: #f3e8ff;
    }

    /* Patient cell */
    .patient-cell {
        display: flex;
        align-items: center;
        gap: 12px;
    }
    .patient-avatar-box {
        width: 40px;
        height: 40px;
        border-radius: 50%;
        background-color: #e0f2fe;
        color: #0284c7;
        font-weight: 600;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 14px;
        flex-shrink: 0;
    }
    .patient-name-title {
        font-weight: 600;
        color: #0f172a;
        margin-bottom: 2px;
    }
    .patient-sub-text {
        font-size: 12.5px;
        color: #64748b;
    }

    /* Detail Card */
    .detail-section-title {
        font-size: 16px;
        font-weight: 700;
        color: #0f172a;
        margin-bottom: 16px;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    .info-label {
        font-size: 13px;
        color: #64748b;
        margin-bottom: 4px;
    }
    .info-value {
        font-size: 14.5px;
        color: #1e293b;
        font-weight: 500;
    }

    .notes-textarea {
        border: 1.5px solid #e2e8f0;
        border-radius: 10px;
        padding: 14px;
        font-size: 14px;
        width: 100%;
        transition: all 0.2s;
        background-color: #f8fafc;
    }
    .notes-textarea:focus {
        background-color: #ffffff;
        border-color: var(--primary-color);
        box-shadow: 0 0 0 3px rgba(0, 139, 116, 0.12);
        outline: none;
    }

    .quick-tag-badge {
        cursor: pointer;
        background: #f1f5f9;
        color: #475569;
        padding: 5px 12px;
        border-radius: 20px;
        font-size: 12.5px;
        font-weight: 500;
        display: inline-block;
        transition: all 0.2s;
        border: 1px solid #e2e8f0;
    }
    .quick-tag-badge:hover {
        background: #e0f2fe;
        color: #0284c7;
        border-color: #bae6fd;
    }

    /* --- Confirmation Modals --- */
    .modal-confirm .modal-content,
    #checkinModal .modal-content,
    #completeModal .modal-content,
    #startExamModal .modal-content {
        border: none;
        border-radius: 16px;
        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
    }

    .modal-confirm .modal-header,
    #checkinModal .modal-header,
    #completeModal .modal-header,
    #startExamModal .modal-header {
        border-bottom: none;
        padding: 24px 24px 0;
        display: flex;
        justify-content: flex-end;
    }

    .modal-confirm .modal-body,
    #checkinModal .modal-body,
    #completeModal .modal-body,
    #startExamModal .modal-body {
        padding: 24px;
        text-align: center;
    }

    .modal-icon-warning {
        width: 64px;
        height: 64px;
        border-radius: 50%;
        background-color: #fef3c7;
        color: #d97706;
        font-size: 28px;
        display: flex;
        align-items: center;
        justify-content: center;
        margin: 0 auto 20px;
    }

    .modal-icon-success {
        width: 64px;
        height: 64px;
        border-radius: 50%;
        background-color: #dcfce7;
        color: #16a34a;
        font-size: 28px;
        display: flex;
        align-items: center;
        justify-content: center;
        margin: 0 auto 20px;
    }

    .modal-title-custom {
        font-size: 20px;
        font-weight: 700;
        color: #0f172a;
        margin-bottom: 12px;
    }

    .modal-text {
        color: #64748b;
        font-size: 14px;
        margin-bottom: 24px;
        line-height: 1.5;
    }

    .modal-actions {
        display: flex;
        justify-content: center;
        gap: 12px;
    }

    .btn-modal-cancel {
        background: white;
        border: 1px solid #cbd5e1;
        color: #475569;
        padding: 10px 24px;
        border-radius: 8px;
        font-weight: 500;
        min-width: 90px;
        transition: all 0.2s ease;
    }

    .btn-modal-cancel:hover {
        background-color: #f8fafc;
        border-color: #94a3b8;
        color: #1e293b;
    }

    .btn-modal-warning {
        background-color: #f59e0b;
        border: none;
        color: white;
        padding: 10px 24px;
        border-radius: 8px;
        font-weight: 500;
        min-width: 100px;
        transition: all 0.2s ease;
    }

    .btn-modal-warning:hover {
        background-color: #d97706;
        color: white;
    }

    .btn-modal-success {
        background-color: #16a34a;
        border: none;
        color: white;
        padding: 10px 24px;
        border-radius: 8px;
        font-weight: 500;
        min-width: 110px;
        transition: all 0.2s ease;
    }

    .btn-modal-success:hover {
        background-color: #15803d;
        color: white;
    }

    .modal-icon-teal {
        width: 64px;
        height: 64px;
        border-radius: 50%;
        background-color: #ecfdf5;
        color: #0d9488;
        font-size: 28px;
        display: flex;
        align-items: center;
        justify-content: center;
        margin: 0 auto 20px;
    }

    .btn-modal-teal {
        background-color: #0d9488;
        border: none;
        color: white;
        padding: 10px 24px;
        border-radius: 8px;
        font-weight: 500;
        min-width: 110px;
        transition: all 0.2s ease;
    }

    .btn-modal-teal:hover {
        background-color: #0f766e;
        color: white;
    }

    .modal-icon-danger {
        width: 64px;
        height: 64px;
        border-radius: 50%;
        background-color: #ffe4e6;
        color: #e11d48;
        font-size: 28px;
        display: flex;
        align-items: center;
        justify-content: center;
        margin: 0 auto 20px;
    }

    .btn-modal-danger {
        background-color: #e11d48;
        border: none;
        color: white;
        padding: 10px 24px;
        border-radius: 8px;
        font-weight: 500;
        min-width: 100px;
        transition: all 0.2s ease;
    }

    .btn-modal-danger:hover {
        background-color: #be123c;
        color: white;
    }

    /* Modern Flash Messages */
    .flash-alert {
        border-radius: 12px !important;
        padding: 12px 18px !important;
        margin-bottom: 20px !important;
        display: flex !important;
        align-items: center !important;
        gap: 14px !important;
        box-shadow: 0 4px 16px rgba(0, 0, 0, 0.04) !important;
        animation: alertSlideDown 0.3s cubic-bezier(0.16, 1, 0.3, 1);
        border-width: 1px !important;
        border-style: solid !important;
        position: relative;
    }

    @keyframes alertSlideDown {
        from {
            opacity: 0;
            transform: translateY(-8px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }

    .flash-alert-success,
    .alert-success {
        background-color: #f0fdf4 !important;
        border-color: #bbf7d0 !important;
        border-left: 5px solid #10b981 !important;
        color: #166534 !important;
    }

    .flash-alert-danger,
    .alert-danger {
        background-color: #fef2f2 !important;
        border-color: #fecaca !important;
        border-left: 5px solid #ef4444 !important;
        color: #991b1b !important;
    }

    .flash-alert-icon {
        width: 32px;
        height: 32px;
        min-width: 32px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 16px;
    }

    .flash-alert-success .flash-alert-icon,
    .alert-success .flash-alert-icon {
        background-color: #10b981;
        color: #ffffff;
        box-shadow: 0 2px 6px rgba(16, 185, 129, 0.35);
    }

    .flash-alert-danger .flash-alert-icon,
    .alert-danger .flash-alert-icon {
        background-color: #ef4444;
        color: #ffffff;
        box-shadow: 0 2px 6px rgba(239, 68, 68, 0.35);
    }

    .flash-alert-content {
        flex-grow: 1;
        font-size: 13.5px;
        font-weight: 500;
        line-height: 1.45;
    }

    .flash-alert-content .alert-title {
        font-weight: 700;
        margin-right: 6px;
    }

    .flash-alert .btn-close {
        padding: 10px !important;
        margin-left: auto !important;
        opacity: 0.55;
        transition: opacity 0.2s;
    }

    .flash-alert .btn-close:hover {
        opacity: 1;
    }
</style>
