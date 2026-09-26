package com.visioncare.dao;

import com.visioncare.model.Department;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO xử lý truy vấn liên quan đến Chuyên khoa.
 */
public class DepartmentDAO {

    /**
     * Lấy danh sách tất cả chuyên khoa.
     */
    public List<Department> getAll() throws Exception {
        List<Department> list = new ArrayList<>();
        list.add(new Department(1, "general", "Nhãn khoa tổng quát", "bi-eye", "Khám và điều trị các bệnh lý về mắt cơ bản."));
        list.add(new Department(2, "lasik", "Khúc xạ và Kính", "bi-eyeglasses", "Đo khúc xạ, cấp đơn kính, tư vấn phẫu thuật LASIK."));
        list.add(new Department(3, "glaucoma", "Glaucoma và Võng mạc", "bi-activity", "Chuyên sâu về cườm nước và bệnh lý võng mạc."));
        return list;
    }

    public Department getByKey(String key) throws Exception {
        for (Department d : getAll()) {
            if (d.getKey().equals(key)) {
                return d;
            }
        }
        return null;
    }
}
