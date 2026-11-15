package com.visioncare.dao;
import com.visioncare.model.Department;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DepartmentDAO {

    public List<Department> getAll() throws Exception {
        List<Department> list = new ArrayList<>();
        list.add(new Department(1, "general",    "Nhãn khoa tổng quát",          "bi-eye",           "Khám và điều trị các bệnh lý về mắt cơ bản."));
        list.add(new Department(2, "refraction", "Khúc xạ & Kính",               "bi-eyeglasses",    "Đo khúc xạ, cấp đơn kính, tư vấn kính áp tròng."));
        list.add(new Department(3, "lasik",      "Phẫu thuật LASIK",             "bi-bullseye",      "Phẫu thuật khúc xạ LASIK, PRK cho mắt cận, loạn, viễn."));
        list.add(new Department(4, "cataract",   "Đục thủy tinh thể (Phaco)",    "bi-camera",        "Phẫu thuật Phaco điều trị đục thủy tinh thể."));
        list.add(new Department(5, "retina",     "Glaucoma & Võng mạc",          "bi-activity",      "Chuyên sâu về cườm nước và bệnh lý võng mạc."));
        list.add(new Department(6, "children",   "Nhãn khoa trẻ em & Nhược thị", "bi-people",        "Khám và điều trị bệnh mắt cho trẻ em, nhược thị, lác."));
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
