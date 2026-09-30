package com.visioncare.dao;

import com.visioncare.model.Department;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO xá»­ lÃ½ truy váº¥n liÃªn quan Ä‘áº¿n ChuyÃªn khoa.
 */
public class DepartmentDAO {

    /**
     * Láº¥y danh sÃ¡ch táº¥t cáº£ chuyÃªn khoa.
     */
    public List<Department> getAll() throws Exception {
        List<Department> list = new ArrayList<>();
        list.add(new Department(1, "general", "NhÃ£n khoa tá»•ng quÃ¡t", "bi-eye", "KhÃ¡m vÃ  Ä‘iá»u trá»‹ cÃ¡c bá»‡nh lÃ½ vá» máº¯t cÆ¡ báº£n."));
        list.add(new Department(2, "lasik", "KhÃºc xáº¡ vÃ  KÃ­nh", "bi-eyeglasses", "Äo khÃºc xáº¡, cáº¥p Ä‘Æ¡n kÃ­nh, tÆ° váº¥n pháº«u thuáº­t LASIK."));
        list.add(new Department(3, "glaucoma", "Glaucoma vÃ  VÃµng máº¡c", "bi-activity", "ChuyÃªn sÃ¢u vá» cÆ°á»m nÆ°á»›c vÃ  bá»‡nh lÃ½ vÃµng máº¡c."));
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
