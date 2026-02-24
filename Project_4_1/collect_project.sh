#!/bin/bash
# STM32 Keil to CMake Migration - Project Collector
# 保存为 collect_project.sh 后执行: chmod +x collect_project.sh && ./collect_project.sh

PROJECT_ROOT="${PWD}"
OUTPUT_FILE="stm32_project_migration.txt"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# 清理旧文件
rm -f "${OUTPUT_FILE}"

# 标题信息
cat >>"${OUTPUT_FILE}" <<EOF
================================================================================
STM32 PROJECT MIGRATION PACKAGE
Generated: ${TIMESTAMP}
Source Path: ${PROJECT_ROOT}
User: $(whoami)
Kernel: $(uname -r)
================================================================================

EOF

# 函数：安全读取文件（跳过二进制/大文件）
safe_cat() {
  local filepath="$1"
  local relpath="${filepath#$PROJECT_ROOT/}"

  # 跳过已知二进制目录
  case "${relpath}" in
  */Objects/* | */Listings/* | *.axf | *.hex | *.bin | *.o | *.d | *.crf | *.lnp | *.tra | *.sct)
    return
    ;;
  esac

  # 检查是否为文本文件
  if file -b --mime-type "${filepath}" | grep -q '^text/'; then
    echo ">>> FILE: ${relpath}" >>"${OUTPUT_FILE}"
    echo ">>> SIZE: $(wc -c <"${filepath}") bytes" >>"${OUTPUT_FILE}"
    echo ">>> MD5: $(md5sum "${filepath}" | awk '{print $1}')" >>"${OUTPUT_FILE}"
    echo "------------------------------------------------------------------------" >>"${OUTPUT_FILE}"
    cat "${filepath}" >>"${OUTPUT_FILE}" 2>/dev/null || echo "[ERROR: Cannot read file]" >>"${OUTPUT_FILE}"
    echo -e "\n\n" >>"${OUTPUT_FILE}"
  fi
}

# 1. 收集 Keil 项目配置（关键！用于提取芯片型号/宏定义/内存布局）
echo "[SECTION: KEIL PROJECT CONFIGURATION]" >>"${OUTPUT_FILE}"
echo "------------------------------------------------------------------------" >>"${OUTPUT_FILE}"
for uvprojx in $(find "${PROJECT_ROOT}" -name "*.uvprojx" -type f | head -1); do
  relpath="${uvprojx#$PROJECT_ROOT/}"
  echo ">>> KEIL PROJECT FILE: ${relpath}" >>"${OUTPUT_FILE}"
  echo ">>> MD5: $(md5sum "${uvprojx}" | awk '{print $1}')" >>"${OUTPUT_FILE}"
  echo "------------------------------------------------------------------------" >>"${OUTPUT_FILE}"
  xmllint --format "${uvprojx}" 2>/dev/null || cat "${uvprojx}" >>"${OUTPUT_FILE}"
  echo -e "\n\n" >>"${OUTPUT_FILE}"
  break # 只取第一个主项目文件
done

# 2. 收集 UV Options（调试/烧录配置）
for uvoptx in $(find "${PROJECT_ROOT}" -name "*.uvoptx" -type f | head -1); do
  relpath="${uvoptx#$PROJECT_ROOT/}"
  echo ">>> UV OPT FILE: ${relpath}" >>"${OUTPUT_FILE}"
  echo ">>> MD5: $(md5sum "${uvoptx}" | awk '{print $1}')" >>"${OUTPUT_FILE}"
  echo "------------------------------------------------------------------------" >>"${OUTPUT_FILE}"
  xmllint --format "${uvoptx}" 2>/dev/null | head -100 >>"${OUTPUT_FILE}" # 只取前100行关键配置
  echo -e "\n\n" >>"${OUTPUT_FILE}"
  break
done

# 3. 收集所有源码文件（按目录分类）
echo "[SECTION: SOURCE CODE FILES]" >>"${OUTPUT_FILE}"
echo "------------------------------------------------------------------------" >>"${OUTPUT_FILE}"

# 定义关键目录顺序（确保 startup 文件优先）
DIRS=("Start" "Library" "System" "Hardware" "User")
for dir in "${DIRS[@]}"; do
  find "${PROJECT_ROOT}" -type d -name "${dir}" | while read -r dirpath; do
    relbase="${dirpath#$PROJECT_ROOT/}"
    echo ">>> DIRECTORY: ${relbase}" >>"${OUTPUT_FILE}"
    echo "------------------------------------------------------------------------" >>"${OUTPUT_FILE}"

    # 先处理 .s 汇编文件（startup 必须优先）
    find "${dirpath}" -maxdepth 1 -type f \( -name "*.s" -o -name "*.S" \) | sort | while read -r f; do
      safe_cat "${f}"
    done

    # 再处理 .c/.h
    find "${dirpath}" -maxdepth 1 -type f \( -name "*.c" -o -name "*.h" \) | sort | while read -r f; do
      safe_cat "${f}"
    done
  done
done

# 4. 系统环境信息（用于诊断工具链兼容性）
echo "[SECTION: BUILD ENVIRONMENT]" >>"${OUTPUT_FILE}"
echo "------------------------------------------------------------------------" >>"${OUTPUT_FILE}"
echo "GCC ARM Version:" >>"${OUTPUT_FILE}"
arm-none-eabi-gcc --version 2>&1 | head -3 >>"${OUTPUT_FILE}" || echo "Not installed" >>"${OUTPUT_FILE}"
echo -e "\nCMake Version:" >>"${OUTPUT_FILE}"
cmake --version 2>&1 | head -1 >>"${OUTPUT_FILE}" || echo "Not installed" >>"${OUTPUT_FILE}"
echo -e "\nNinja Version:" >>"${OUTPUT_FILE}"
ninja --version 2>&1 >>"${OUTPUT_FILE}" || echo "Not installed" >>"${OUTPUT_FILE}"
echo -e "\nOpenOCD Version:" >>"${OUTPUT_FILE}"
openocd --version 2>&1 | head -1 >>"${OUTPUT_FILE}" 2>/dev/null || echo "Not installed" >>"${OUTPUT_FILE}"
echo -e "\nST-Link Version:" >>"${OUTPUT_FILE}"
st-info --version 2>&1 >>"${OUTPUT_FILE}" 2>/dev/null || echo "Not installed" >>"${OUTPUT_FILE}"
echo -e "\n" >>"${OUTPUT_FILE}"

# 5. 项目结构快照（辅助分析）
echo "[SECTION: DIRECTORY STRUCTURE]" >>"${OUTPUT_FILE}"
echo "------------------------------------------------------------------------" >>"${OUTPUT_FILE}"
tree -L 3 -I 'Objects|Listings|*.o|*.axf|*.hex|*.bin' "${PROJECT_ROOT}" 2>/dev/null || find "${PROJECT_ROOT}" -type f -name "*.c" -o -name "*.h" -o -name "*.s" | sed "s|${PROJECT_ROOT}/||" | sort >>"${OUTPUT_FILE}"
echo -e "\n\n" >>"${OUTPUT_FILE}"

# 结尾标记
cat >>"${OUTPUT_FILE}" <<EOF
================================================================================
END OF MIGRATION PACKAGE
Total Size: $(wc -c <"${OUTPUT_FILE}") bytes
================================================================================
EOF

echo "✅ 项目收集完成！文件已生成: ${OUTPUT_FILE}"
echo "👉 请将此文件发送给我，我将为您:"
echo "   1. 解析 Keil 配置提取芯片型号/内存布局/宏定义"
echo "   2. 生成完整的 CMakeLists.txt (支持多配置)"
echo "   3. 创建 Ninja 构建脚本"
echo "   4. 提供 OpenOCD 烧录配置"
echo "   5. 修复常见迁移陷阱（如 startup 文件链接顺序、syscalls 实现等）"
