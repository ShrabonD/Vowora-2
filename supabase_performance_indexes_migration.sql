-- ============================================================================
-- VOWORA - SUPABASE PERFORMANCE INDEXES & QUERY OPTIMIZATION MIGRATION
-- ============================================================================
-- PURPOSE:
-- 1. Add targeted B-Tree indexes on foreign keys and lookup columns to eliminate slow table scans.
-- 2. Optimize event-specific guest, payment, photo, schedule, and booking queries.
-- 3. Ensure lightning-fast real-time stream subscriptions and relational lookups.
-- ============================================================================

-- 1. Index on wedding_profiles user_id for multi-account user wedding lookups
CREATE INDEX IF NOT EXISTS idx_wedding_profiles_user_id
    ON public.wedding_profiles(user_id);

-- 2. Index on guests wedding_id for fast event-scoped guest management & RSVP filtering
CREATE INDEX IF NOT EXISTS idx_guests_wedding_id
    ON public.guests(wedding_id);

-- 3. Index on service_bookings wedding_id for fast vendor booking synchronization
CREATE INDEX IF NOT EXISTS idx_service_bookings_wedding_id
    ON public.service_bookings(wedding_id);

-- 4. Index on wedding_photos wedding_id for fast gallery loading
CREATE INDEX IF NOT EXISTS idx_wedding_photos_wedding_id
    ON public.wedding_photos(wedding_id);

-- 5. Index on payment_records wedding_id for fast invoice and payment ledger lookups
CREATE INDEX IF NOT EXISTS idx_payment_records_wedding_id
    ON public.payment_records(wedding_id);

-- 6. Index on wedding_schedule wedding_id for fast ceremony timeline retrieval
CREATE INDEX IF NOT EXISTS idx_wedding_schedule_wedding_id
    ON public.wedding_schedule(wedding_id);

-- 7. Composite index on guests for wedding_id and rsvp_status counting optimization
CREATE INDEX IF NOT EXISTS idx_guests_wedding_id_rsvp_status
    ON public.guests(wedding_id, rsvp_status);

-- ============================================================================
-- ROLLBACK SCRIPT (In case rollback is required)
-- ============================================================================
/*
DROP INDEX IF EXISTS public.idx_wedding_profiles_user_id;
DROP INDEX IF EXISTS public.idx_guests_wedding_id;
DROP INDEX IF EXISTS public.idx_service_bookings_wedding_id;
DROP INDEX IF EXISTS public.idx_wedding_photos_wedding_id;
DROP INDEX IF EXISTS public.idx_payment_records_wedding_id;
DROP INDEX IF EXISTS public.idx_wedding_schedule_wedding_id;
DROP INDEX IF EXISTS public.idx_guests_wedding_id_rsvp_status;
*/
