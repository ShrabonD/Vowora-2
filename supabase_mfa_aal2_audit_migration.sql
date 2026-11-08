-- ============================================================================
-- VOWORA - SUPABASE RLS & OPTIONAL TOTP MFA (AAL2) AUDIT MIGRATION
-- ============================================================================
-- PURPOSE:
-- 1. Implement secure optional TOTP MFA enforcement for protected manager operations.
--    - Users WITHOUT MFA enrolled retain authorized aal1 access.
--    - Users WITH MFA enrolled must satisfy aal2 (2FA verified) for write/manager operations.
-- 2. Preserve guest invitation-code joining and public read paths.
-- 3. Prevent cross-manager data leakage (restricting modifications to event owners).
-- ============================================================================

-- 1. CREATE HELPER FUNCTION FOR OPTIONAL MFA AAL2 ENFORCEMENT
CREATE OR REPLACE FUNCTION public.satisfies_mfa_aal()
RETURNS BOOLEAN AS $$
DECLARE
    uid UUID;
    has_mfa BOOLEAN;
    current_aal TEXT;
BEGIN
    uid := auth.uid();
    IF uid IS NULL THEN
        RETURN FALSE;
    END IF;

    -- Check if user has enrolled verified TOTP factors
    SELECT EXISTS (
        SELECT 1 FROM auth.mfa_factors
        WHERE auth.mfa_factors.user_id = uid
        AND auth.mfa_factors.status = 'verified'
    ) INTO has_mfa;

    -- If user has no MFA factors enrolled, allow aal1 access
    IF NOT has_mfa THEN
        RETURN TRUE;
    END IF;

    -- If MFA is enrolled, require aal2 assurance level
    current_aal := auth.jwt() ->> 'aal';
    RETURN current_aal = 'aal2';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION public.satisfies_mfa_aal() IS
'Enforces aal2 for users who have enrolled MFA, while allowing aal1 for users without MFA.';


-- 2. AUDIT & UPDATE WEDDING PROFILES RLS POLICIES
-- Allow public/invited read by wedding ID or invitation code, but restrict owner writes to owner + MFA AAL2 check.

ALTER TABLE public.wedding_profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Weddings are viewable by anyone with wedding_id or invitation code" ON public.wedding_profiles;
DROP POLICY IF EXISTS "Wedding owners can manage their weddings" ON public.wedding_profiles;

-- Public/Guest read access (needed for guest joining & public event pages)
CREATE POLICY "Weddings are viewable by anyone with wedding_id or invitation code"
    ON public.wedding_profiles FOR SELECT
    USING (true);

-- Owner write access protected by owner ID and optional MFA AAL2 enforcement
CREATE POLICY "Wedding owners can manage their weddings"
    ON public.wedding_profiles FOR ALL
    USING (user_id = auth.uid() AND public.satisfies_mfa_aal())
    WITH CHECK (user_id = auth.uid() AND public.satisfies_mfa_aal());


-- 3. AUDIT & UPDATE GUESTS & RSVP RLS POLICIES
-- Allow guest RSVP submissions, but restrict guest list management to wedding owners satisfying MFA AAL2.

ALTER TABLE public.guests ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view and submit guest RSVP" ON public.guests;
DROP POLICY IF EXISTS "Owners manage wedding guests" ON public.guests;

-- Anyone can view & submit RSVP for invitation codes
CREATE POLICY "Anyone can view and submit guest RSVP"
    ON public.guests FOR SELECT
    USING (true);

CREATE POLICY "Anyone can submit guest RSVP"
    ON public.guests FOR INSERT
    WITH CHECK (true);

-- Only event owners with satisfied MFA can update/delete guest lists
CREATE POLICY "Owners manage wedding guests"
    ON public.guests FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.wedding_profiles
            WHERE public.wedding_profiles.id = public.guests.wedding_id
            AND public.wedding_profiles.user_id = auth.uid()
        ) AND public.satisfies_mfa_aal()
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.wedding_profiles
            WHERE public.wedding_profiles.id = public.guests.wedding_id
            AND public.wedding_profiles.user_id = auth.uid()
        ) AND public.satisfies_mfa_aal()
    );

CREATE POLICY "Owners delete wedding guests"
    ON public.guests FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM public.wedding_profiles
            WHERE public.wedding_profiles.id = public.guests.wedding_id
            AND public.wedding_profiles.user_id = auth.uid()
        ) AND public.satisfies_mfa_aal()
    );


-- 4. AUDIT & UPDATE PROFILES RLS POLICIES
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Profiles are viewable by authenticated users" ON public.profiles;
DROP POLICY IF EXISTS "Users can insert their own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON public.profiles;

CREATE POLICY "Profiles are viewable by authenticated users"
    ON public.profiles FOR SELECT
    USING (true);

CREATE POLICY "Users can insert their own profile"
    ON public.profiles FOR INSERT
    WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
    ON public.profiles FOR UPDATE
    USING (auth.uid() = id AND public.satisfies_mfa_aal())
    WITH CHECK (auth.uid() = id AND public.satisfies_mfa_aal());


-- ============================================================================
-- ROLLBACK SCRIPT (In case rollback is required)
-- ============================================================================
/*
-- 1. Drop MFA helper function
DROP FUNCTION IF EXISTS public.satisfies_mfa_aal();

-- 2. Restore wedding_profiles policies
DROP POLICY IF EXISTS "Wedding owners can manage their weddings" ON public.wedding_profiles;
CREATE POLICY "Weddings are viewable by anyone with wedding_id or invitation code"
    ON public.wedding_profiles FOR ALL USING (true);

-- 3. Restore guests policies
DROP POLICY IF EXISTS "Owners manage wedding guests" ON public.guests;
DROP POLICY IF EXISTS "Owners delete wedding guests" ON public.guests;
DROP POLICY IF EXISTS "Anyone can submit guest RSVP" ON public.guests;
CREATE POLICY "Anyone can view and submit guest RSVP"
    ON public.guests FOR ALL USING (true);

-- 4. Restore profiles policies
DROP POLICY IF EXISTS "Users can update their own profile" ON public.profiles;
CREATE POLICY "Users can update their own profile"
    ON public.profiles FOR UPDATE USING (true);
*/
