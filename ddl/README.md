# DDL

포트폴리오에서 데이터베이스 설계와 샘플 데이터를 보여주기 위한 공간입니다.

PostgreSQL 컨테이너가 처음 만들어질 때 이 폴더의 `.sql` 파일이 파일명 순서대로 실행됩니다.
이미 `db_data` 볼륨이 만들어진 뒤에는 자동으로 다시 실행되지 않습니다.

## 파일

- `001_schema.sql`: 테이블, 인덱스 등 스키마 정의
- `002_seed.sql`: 화면 확인용 샘플 데이터

## 포함된 모델링 예시

- `todos`: 앱 동작 확인용 기본 테이블
- `bom_parts`: BOM 구조를 표현하는 self join 테이블
- `entities`, `entity_attributes`, `entity_attribute_values`: 속성 확장이 쉬운 EAV 모델

## 예시 쿼리

BOM 전체 트리 조회:

```sql
WITH RECURSIVE bom_tree AS (
    SELECT
        id,
        parent_id,
        sku,
        name,
        quantity,
        unit,
        0 AS depth,
        ARRAY[sort_order, id] AS path
    FROM bom_parts
    WHERE parent_id IS NULL

    UNION ALL

    SELECT
        child.id,
        child.parent_id,
        child.sku,
        child.name,
        child.quantity,
        child.unit,
        parent.depth + 1,
        parent.path || child.sort_order || child.id
    FROM bom_parts child
    JOIN bom_tree parent ON parent.id = child.parent_id
)
SELECT depth, sku, name, quantity, unit
FROM bom_tree
ORDER BY path;
```

EAV 값을 행 형태로 조회:

```sql
SELECT
    e.entity_type,
    e.code,
    e.display_name,
    a.code AS attribute_code,
    a.label,
    COALESCE(
        v.value_text,
        v.value_number::TEXT,
        v.value_boolean::TEXT,
        v.value_date::TEXT
    ) AS value
FROM entities e
JOIN entity_attribute_values v ON v.entity_id = e.id
JOIN entity_attributes a ON a.id = v.attribute_id
ORDER BY e.entity_type, e.code, a.sort_order;
```

## 다시 초기화하고 싶을 때

```bash
docker compose down -v
docker compose up --build
```

`down -v`는 PostgreSQL 볼륨을 삭제하므로 기존 DB 데이터가 사라집니다.
