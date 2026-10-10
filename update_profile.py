import os, glob, re

files = glob.glob(r'e:\Github\SWP-project\web\views\profile\*.jsp')

sidebar_template = '''          <div class="col-lg-3">
            <div class="content-card text-center border-0 mb-4 mb-lg-0" style="padding: 30px 20px;">
              <div class="mb-3">
                <span class="badge bg-light text-dark rounded-pill border px-3 py-1">Avatar</span>
              </div>
              <h4 class="fw-bold" style="color: #1e293b; font-size: 18px;">${not empty sessionScope.user.fullName ? sessionScope.user.fullName : 'Nguyễn Văn A'}</h4>
              <p class="text-muted small mb-4">
                <c:choose>
                    <c:when test="${sessionScope.user.role == 'admin'}">Super Admin</c:when>
                    <c:when test="${sessionScope.user.role == 'manager'}">Manager</c:when>
                    <c:when test="${sessionScope.user.role == 'doctor'}">Bác sĩ</c:when>
                    <c:when test="${sessionScope.user.role == 'medical_specialist'}">Bác sĩ Chuyên khoa</c:when>
                    <c:when test="${sessionScope.user.role == 'staff'}">Nhân viên</c:when>
                    <c:otherwise>Bệnh nhân</c:otherwise>
                </c:choose>
              </p>
              
              <ul class="sidebar-menu text-start">
                <li>
                  <a href="${pageContext.request.contextPath}/views/profile/manage.jsp" class="{manage_active}"><i class="bi bi-person"></i> Thông tin chung</a>
                </li>
                <c:if test="${sessionScope.user.role == 'patient'}">
                    <li>
                    <a href="${pageContext.request.contextPath}/views/profile/appointment-history.jsp" class="{appt_active}"><i class="bi bi-calendar-check"></i> Lịch sử hẹn khám</a>
                    </li>
                    <li>
                    <a href="${pageContext.request.contextPath}/views/profile/medical-history.jsp" class="{med_active}"><i class="bi bi-journal-medical"></i> Lịch sử khám bệnh</a>
                    </li>
                    <li>
                    <a href="${pageContext.request.contextPath}/views/profile/refund-request.jsp" class="{refund_active}"><i class="bi bi-cash-coin"></i> Yêu cầu hoàn tiền</a>
                    </li>
                </c:if>
                <li>
                  <a href="${pageContext.request.contextPath}/views/profile/change-password.jsp" class="{pwd_active}"><i class="bi bi-key"></i> Đổi mật khẩu</a>
                </li>
                <li class="mt-3 pt-3" style="border-top: 1px solid #f1f5f9;">
                  <a href="${pageContext.request.contextPath}/logout" class="text-danger"><i class="bi bi-box-arrow-right"></i> Đăng xuất</a>
                </li>
              </ul>
            </div>
          </div>'''

css_append = '''
    /* Admin UI Sync */
    .content-card {
        background: white;
        border-radius: 12px;
        box-shadow: 0 1px 3px rgba(0,0,0,0.05);
        border: 1px solid rgba(0,0,0,0.05);
        overflow: hidden;
    }
    .sidebar-menu {
        padding: 0;
        list-style: none;
        margin: 0;
    }
    .sidebar-menu li {
        margin-bottom: 4px;
    }
    .sidebar-menu li a {
        display: flex;
        align-items: center;
        padding: 12px 16px;
        color: #64748b;
        text-decoration: none;
        border-radius: 8px;
        font-weight: 500;
        font-size: 14px;
        transition: all 0.2s ease;
    }
    .sidebar-menu li a i {
        margin-right: 12px;
        font-size: 18px;
        color: #94a3b8;
    }
    .sidebar-menu li a:hover {
        background-color: #f8fafc;
        color: #0f172a;
    }
    .sidebar-menu li a:hover i {
        color: #64748b;
    }
    .sidebar-menu li a.active {
        background-color: #f0f7f6;
        color: #0d9488;
        font-weight: 600;
    }
    .sidebar-menu li a.active i {
        color: #0d9488;
    }
    .sidebar-menu li a.text-danger:hover {
        background-color: #fef2f2;
        color: #ef4444 !important;
    }
    .sidebar-menu li a.text-danger i {
        color: #ef4444;
    }
    /* Form overrides */
    .form-control, .form-select {
        border-radius: 8px;
        border: 1px solid #e2e8f0;
        padding: 10px 16px;
        font-size: 14px;
    }
    .form-control:focus, .form-select:focus {
        border-color: #0d9488;
        box-shadow: 0 0 0 3px rgba(13,148,136,0.1);
    }
    .btn-primary-custom {
        background-color: #0d9488;
        color: white;
        border: none;
        padding: 10px 20px;
        border-radius: 8px;
        font-weight: 500;
        font-size: 14px;
        transition: all 0.2s;
    }
    .btn-primary-custom:hover {
        background-color: #0f766e;
        color: white;
    }
'''

for file in files:
    with open(file, 'r', encoding='utf-8') as f:
        content = f.read()

    manage_active = 'active' if 'manage.jsp' in file else ''
    appt_active = 'active' if 'appointment-history.jsp' in file else ''
    med_active = 'active' if 'medical-history.jsp' in file else ''
    refund_active = 'active' if 'refund-request.jsp' in file else ''
    pwd_active = 'active' if 'change-password.jsp' in file else ''

    new_sidebar = sidebar_template.format(
        manage_active=manage_active,
        appt_active=appt_active,
        med_active=med_active,
        refund_active=refund_active,
        pwd_active=pwd_active
    )

    pattern = re.compile(r'<div class="col-lg-3">.*?</div>\s*</div>\s*<div class="col-lg-9', re.DOTALL)
    if pattern.search(content):
        content = pattern.sub(new_sidebar + '\n          <div class="col-lg-9', content)
        
        if '/* Admin UI Sync */' not in content:
            style_pattern = re.compile(r'</style>')
            content = style_pattern.sub(css_append + '\n  </style>', content)

        content = content.replace('btn w-100 py-2 mb-4 text-white', 'btn-primary-custom w-100 py-2 mb-4')
        content = content.replace('btn btn-custom', 'btn btn-primary-custom')
        content = content.replace('style="border-radius: 8px; font-size: 16px; font-weight: 500; background-color: #0d9488; border-color: #0d9488;"', '')
        
        if 'manage.jsp' in file or 'change-password.jsp' in file or 'refund-request.jsp' in file:
            content = content.replace('<hr class="mb-4">\n              \n              <form', '<hr class="mb-4">\n              <div class="content-card p-4">\n              <form')
            content = content.replace('<hr class="mb-4">\n\n              <c:if', '<hr class="mb-4">\n              <div class="content-card p-4">\n              <c:if')
            
            content = content.replace('</form>\n            </div>\n          </div>', '</form>\n              </div>\n            </div>\n          </div>')
            content = content.replace('</form>\n\n            </div>\n          </div>', '</form>\n              </div>\n            </div>\n          </div>')
            
            if 'refund-request.jsp' in file:
                content = content.replace('<div class="table-responsive">', '<div class="content-card mb-5">\n                <div class="table-responsive">')
                content = content.replace('</table>\n              </div>', '</table>\n                </div>\n              </div>')
                content = content.replace('<table class="table table-borderless table-striped align-middle">', '<table class="custom-table">')
                content = content.replace('<thead class="table-light">', '<thead>')

        if 'appointment-history.jsp' in file:
            content = content.replace('<table class="table table-borderless table-striped align-middle mt-3">', '<div class="content-card"><div class="table-responsive"><table class="custom-table">')
            content = content.replace('</table>\n                  </div>', '</table></div></div>\n                  </div>')
            content = content.replace('<thead class="table-light">', '<thead>')
            content = content.replace('<div class="table-responsive mt-3">', '<div class="content-card mt-3"><div class="table-responsive">')

        with open(file, 'w', encoding='utf-8') as f:
            f.write(content)
        print('Updated', file)
    else:
        print('Could not find sidebar pattern in', file)
