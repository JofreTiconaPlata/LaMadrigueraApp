ALTER TABLE "parqueos"
ADD COLUMN IF NOT EXISTS "operador_id" INTEGER;

ALTER TABLE "parqueos"
ADD COLUMN IF NOT EXISTS "qr_pago_url" TEXT;

UPDATE "parqueos"
SET "operador_id" = (
  SELECT "id"
  FROM "usuarios"
  WHERE "rol" = 'OPERADOR'
  ORDER BY "id"
  LIMIT 1
)
WHERE "operador_id" IS NULL;

DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM "parqueos" WHERE "operador_id" IS NULL) THEN
    RAISE EXCEPTION 'No se puede completar la migracion: existen parqueos sin operador y no hay usuario OPERADOR disponible.';
  END IF;
END $$;

ALTER TABLE "parqueos"
ALTER COLUMN "operador_id" SET NOT NULL;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'parqueos_operador_id_fkey'
  ) THEN
    ALTER TABLE "parqueos"
    ADD CONSTRAINT "parqueos_operador_id_fkey"
    FOREIGN KEY ("operador_id") REFERENCES "usuarios"("id")
    ON DELETE RESTRICT ON UPDATE CASCADE;
  END IF;
END $$;
