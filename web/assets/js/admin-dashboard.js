(function () {
    function contextPath() {
        return window.WEARCONNECT_CTX || '';
    }

    function openPaymentModal(orderID, depositAmount, totalAmount) {
        document.getElementById('paymentOrderID').value = orderID;
        document.getElementById('depositDisplay').textContent = parseFloat(depositAmount).toLocaleString('vi-VN');
        document.getElementById('rentalDisplay').textContent = parseFloat(totalAmount).toLocaleString('vi-VN');
        document.getElementById('paymentModal').classList.add('show');
    }

    function openPaymentModalFromButton(button) {
        const container = button.parentElement;
        const orderID = container.querySelector('.payment-order-id')?.textContent?.trim();
        const depositAmount = container.querySelector('.payment-deposit-amount')?.textContent?.trim();
        const totalAmount = container.querySelector('.payment-total-amount')?.textContent?.trim();
        if (!orderID) {
            alert('Không tìm thấy thông tin đơn hàng.');
            return;
        }
        openPaymentModal(orderID, depositAmount || '0', totalAmount || '0');
    }

    function closePaymentModal() {
        document.getElementById('paymentModal').classList.remove('show');
    }

    function viewProductDetailsFromButton(button) {
        const container = button.parentElement;
        const clothingID = container.querySelector('.clothing-id-data')?.textContent?.trim();
        if (!clothingID) {
            alert('Không tìm thấy mã sản phẩm.');
            return;
        }
        viewProductDetails(clothingID);
    }

    function openDeactivateModal(id) {
        document.getElementById('deactivateClothingID').value = id;
        document.getElementById('deactivateModal').classList.add('show');
    }

    function openDeactivateModalFromButton(button) {
        const container = button.parentElement;
        const clothingID = container.querySelector('.clothing-id-data')?.textContent?.trim();
        if (!clothingID) {
            alert('Không tìm thấy mã sản phẩm.');
            return;
        }
        openDeactivateModal(clothingID);
    }

    function closeDeactivateModal() {
        document.getElementById('deactivateModal').classList.remove('show');
    }

    function viewProductDetails(clothingID) {
        fetch(contextPath() + '/clothing?action=getDetails&id=' + clothingID)
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    const p = data.product;
                    let html = '<div style="display: grid; gap: 12px;">';

                    if (p.imagePath) {
                        html += '<div><img src="' + contextPath() + '/image?id=' + p.clothingID + '" style="width: 100%; max-height: 300px; object-fit: cover; border-radius: 6px;"></div>';
                    }

                    html += '<div style="border-bottom: 1px solid #eee; padding-bottom: 12px;">';
                    html += '<p><strong>ID:</strong> ' + p.clothingID + '</p>';
                    html += '<p><strong>Tên sản phẩm:</strong> ' + p.clothingName + '</p>';
                    html += '<p><strong>Danh mục:</strong> ' + p.category + '</p>';
                    if (p.category !== 'Cosplay') {
                        html += '<p><strong>Phong cách:</strong> ' + p.style + '</p>';
                    }
                    html += '<p><strong>Dịp:</strong> ' + p.occasion + '</p>';
                    html += '</div>';

                    html += '<div style="border-bottom: 1px solid #eee; padding-bottom: 12px;">';
                    html += '<p><strong>Giá theo giờ:</strong> ' + new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(p.hourlyPrice) + '</p>';
                    html += '<p><strong>Giá theo ngày:</strong> ' + new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(p.dailyPrice) + '</p>';
                    html += '<p><strong>Item value:</strong> ' + new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(p.itemValue) + '</p>';
                    html += '</div>';

                    html += '<div style="border-bottom: 1px solid #eee; padding-bottom: 12px;">';
                    html += '<p><strong>Size:</strong> ' + p.size + '</p>';
                    if (p.category === 'Cosplay' && p.cosplayDetail && p.cosplayDetail.accessoryList) {
                        html += '<p><strong>Phụ kiện đi kèm:</strong> ' + p.cosplayDetail.accessoryList + '</p>';
                    }
                    html += '<p><strong>Số lượng:</strong> ' + p.quantity + '</p>';
                    html += '<p><strong>Mô tả:</strong> ' + (p.description || 'N/A') + '</p>';
                    html += '</div>';

                    html += '<div style="border-bottom: 1px solid #eee; padding-bottom: 12px;">';
                    html += '<p><strong>Có sẵn từ:</strong> ' + p.availableFrom + '</p>';
                    html += '<p><strong>Có sẵn đến:</strong> ' + p.availableTo + '</p>';
                    html += '</div>';

                    html += '<div>';
                    html += '<p><strong>Trạng thái:</strong> <span style="padding: 4px 8px; border-radius: 4px; ';
                    if (p.clothingStatus === 'ACTIVE' || p.clothingStatus === 'APPROVED_COSPLAY') {
                        html += 'background: #d4edda; color: #155724;';
                    } else if (p.clothingStatus === 'INACTIVE') {
                        html += 'background: #f8d7da; color: #721c24;';
                    } else {
                        html += 'background: #fff3cd; color: #856404;';
                    }
                    html += '">' + p.clothingStatus + '</span></p>';
                    html += '<p><strong>Hoạt động:</strong> ' + (p.active ? 'Có' : 'Không') + '</p>';
                    html += '</div>';

                    html += '</div>';
                    document.getElementById('detailsContent').innerHTML = html;
                    document.getElementById('detailsModal').classList.add('show');
                } else {
                    alert('Không thể tải chi tiết sản phẩm');
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('Lỗi khi tải chi tiết sản phẩm');
            });
    }

    function closeDetailsModal() {
        document.getElementById('detailsModal').classList.remove('show');
    }

    function loadKnowledgeDocs() {
        const tableBody = document.getElementById('knowledgeTableBody');
        if (!tableBody) return;

        const query = encodeURIComponent(document.getElementById('knowledgeSearchInput').value || '');
        const includeInactive = document.getElementById('knowledgeIncludeInactive').checked;
        const statusText = document.getElementById('knowledgeStatus');

        statusText.textContent = 'Đang tải...';
        fetch(contextPath() + '/admin/ai-knowledge?q=' + query + '&includeInactive=' + includeInactive + '&limit=100')
            .then(response => response.json())
            .then(data => {
                if (!data.success) {
                    throw new Error(data.error || 'Không tải được dữ liệu');
                }

                const docs = data.data || [];
                if (docs.length === 0) {
                    tableBody.innerHTML = '<tr><td colspan="7" class="empty-message">Chưa có tài liệu tri thức.</td></tr>';
                    statusText.textContent = '0 tài liệu';
                    return;
                }

                const rows = docs.map(doc => {
                    const safeTitle = escapeHtml(doc.title || '');
                    const safeCategory = escapeHtml(doc.category || '');
                    const safeTags = escapeHtml(doc.tags || '');
                    const statusLabel = doc.isActive ? '<span class="status-active">Hoạt động</span>' : '<span class="status-inactive">Đã ẩn</span>';
                    const updatedBy = doc.updatedBy ? ('#' + doc.updatedBy) : '-';
                    const updatedAt = doc.updatedAt || '-';

                    return '<tr>'
                        + '<td>' + doc.docID + '</td>'
                        + '<td>' + safeTitle + '</td>'
                        + '<td>' + safeCategory + '</td>'
                        + '<td>' + safeTags + '</td>'
                        + '<td>' + statusLabel + '</td>'
                        + '<td>' + escapeHtml(updatedAt) + ' (' + escapeHtml(updatedBy) + ')</td>'
                        + '<td>'
                        + '<div class="action-buttons">'
                        + '<button type="button" class="btn btn-toggle" onclick="editKnowledgeDoc(' + doc.docID + ')">Sửa</button>'
                        + '<button type="button" class="btn btn-delete" onclick="deactivateKnowledgeDoc(' + doc.docID + ')">Ẩn</button>'
                        + '</div>'
                        + '</td>'
                        + '</tr>';
                }).join('');

                tableBody.innerHTML = rows;
                statusText.textContent = docs.length + ' tài liệu';
            })
            .catch(error => {
                console.error(error);
                tableBody.innerHTML = '<tr><td colspan="7" class="empty-message">Lỗi tải dữ liệu tri thức.</td></tr>';
                statusText.textContent = 'Lỗi tải dữ liệu';
            });
    }

    function loadKnowledgeAuditLogs() {
        const tableBody = document.getElementById('knowledgeAuditTableBody');
        if (!tableBody) return;

        const docID = document.getElementById('auditDocIDInput').value;
        const operatorID = document.getElementById('auditOperatorIDInput').value;
        const action = document.getElementById('auditActionInput').value;
        const statusText = document.getElementById('knowledgeAuditStatus');

        const params = new URLSearchParams();
        params.set('action', 'audit');
        params.set('limit', '100');
        if (docID) params.set('docID', docID);
        if (operatorID) params.set('operatorID', operatorID);
        if (action) params.set('auditAction', action);

        statusText.textContent = 'Đang tải...';
        fetch(contextPath() + '/admin/ai-knowledge?' + params.toString())
            .then(response => response.json())
            .then(data => {
                if (!data.success) {
                    throw new Error(data.error || 'Không tải được audit');
                }

                const logs = data.data || [];
                if (logs.length === 0) {
                    tableBody.innerHTML = '<tr><td colspan="7" class="empty-message">Không có bản ghi audit phù hợp.</td></tr>';
                    statusText.textContent = '0 bản ghi';
                    return;
                }

                const rows = logs.map(log => {
                    const operator = '#' + (log.operatorID || '-') + (log.operatorRole ? (' (' + escapeHtml(log.operatorRole) + ')') : '');
                    return '<tr>'
                        + '<td>' + (log.auditID || '-') + '</td>'
                        + '<td>' + (log.docID || '-') + '</td>'
                        + '<td>' + escapeHtml(log.action || '-') + '</td>'
                        + '<td>' + operator + '</td>'
                        + '<td title="' + escapeHtml(log.afterSnapshot || '') + '">' + escapeHtml(log.summary || '-') + '</td>'
                        + '<td>' + escapeHtml(log.ipAddress || '-') + '</td>'
                        + '<td>' + escapeHtml(log.createdAt || '-') + '</td>'
                        + '</tr>';
                }).join('');

                tableBody.innerHTML = rows;
                statusText.textContent = logs.length + ' bản ghi';
            })
            .catch(error => {
                console.error(error);
                tableBody.innerHTML = '<tr><td colspan="7" class="empty-message">Lỗi tải audit log.</td></tr>';
                statusText.textContent = 'Lỗi tải audit';
            });
    }

    function editKnowledgeDoc(docID) {
        fetch(contextPath() + '/admin/ai-knowledge?docID=' + docID)
            .then(response => response.json())
            .then(data => {
                if (!data.success || !data.data) {
                    throw new Error(data.error || 'Không tìm thấy tài liệu');
                }

                const doc = data.data;
                document.getElementById('knowledgeDocID').value = doc.docID || '';
                document.getElementById('knowledgeTitle').value = doc.title || '';
                document.getElementById('knowledgeCategory').value = doc.category || '';
                document.getElementById('knowledgeTags').value = doc.tags || '';
                document.getElementById('knowledgeContent').value = doc.content || '';
                document.getElementById('knowledgeIsActive').checked = !!doc.isActive;
                document.getElementById('knowledgeSubmitBtn').textContent = 'Cập nhật';
                document.getElementById('knowledgeTitle').focus();
            })
            .catch(error => {
                console.error(error);
                alert('Không thể tải chi tiết tài liệu.');
            });
    }

    function deactivateKnowledgeDoc(docID) {
        if (!confirm('Bạn có chắc muốn ẩn tài liệu tri thức này?')) return;

        fetch(contextPath() + '/admin/ai-knowledge', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ action: 'delete', docID: docID })
        })
            .then(response => response.json())
            .then(data => {
                if (!data.success) {
                    throw new Error(data.error || 'Xóa thất bại');
                }
                loadKnowledgeDocs();
            })
            .catch(error => {
                console.error(error);
                alert('Không thể ẩn tài liệu.');
            });
    }

    function resetKnowledgeForm() {
        const form = document.getElementById('knowledgeForm');
        if (!form) return;
        form.reset();
        document.getElementById('knowledgeDocID').value = '';
        document.getElementById('knowledgeIsActive').checked = true;
        document.getElementById('knowledgeSubmitBtn').textContent = 'Tạo mới';
    }

    function submitKnowledgeForm(event) {
        event.preventDefault();

        const docID = document.getElementById('knowledgeDocID').value;
        const payload = {
            action: docID ? 'update' : 'create',
            docID: docID ? Number(docID) : undefined,
            title: document.getElementById('knowledgeTitle').value.trim(),
            category: document.getElementById('knowledgeCategory').value.trim(),
            tags: document.getElementById('knowledgeTags').value.trim(),
            content: document.getElementById('knowledgeContent').value.trim(),
            isActive: document.getElementById('knowledgeIsActive').checked
        };

        fetch(contextPath() + '/admin/ai-knowledge', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        })
            .then(response => response.json())
            .then(data => {
                if (!data.success) {
                    throw new Error(data.error || 'Lưu thất bại');
                }
                resetKnowledgeForm();
                loadKnowledgeDocs();
            })
            .catch(error => {
                console.error(error);
                alert('Không thể lưu tài liệu tri thức.');
            });
    }

    function escapeHtml(text) {
        return String(text)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/\"/g, '&quot;')
            .replace(/'/g, '&#039;');
    }

    document.addEventListener('DOMContentLoaded', function () {
        const form = document.getElementById('knowledgeForm');
        const search = document.getElementById('knowledgeSearchInput');
        const includeInactive = document.getElementById('knowledgeIncludeInactive');

        if (form) {
            form.addEventListener('submit', submitKnowledgeForm);
            loadKnowledgeDocs();
            loadKnowledgeAuditLogs();
        }

        if (search) {
            search.addEventListener('keydown', function (event) {
                if (event.key === 'Enter') {
                    event.preventDefault();
                    loadKnowledgeDocs();
                }
            });
        }

        if (includeInactive) {
            includeInactive.addEventListener('change', loadKnowledgeDocs);
        }
    });

    window.openPaymentModal = openPaymentModal;
    window.openPaymentModalFromButton = openPaymentModalFromButton;
    window.closePaymentModal = closePaymentModal;
    window.viewProductDetailsFromButton = viewProductDetailsFromButton;
    window.openDeactivateModal = openDeactivateModal;
    window.openDeactivateModalFromButton = openDeactivateModalFromButton;
    window.closeDeactivateModal = closeDeactivateModal;
    window.viewProductDetails = viewProductDetails;
    window.closeDetailsModal = closeDetailsModal;
    window.loadKnowledgeDocs = loadKnowledgeDocs;
    window.loadKnowledgeAuditLogs = loadKnowledgeAuditLogs;
    window.editKnowledgeDoc = editKnowledgeDoc;
    window.deactivateKnowledgeDoc = deactivateKnowledgeDoc;
    window.resetKnowledgeForm = resetKnowledgeForm;
})();
