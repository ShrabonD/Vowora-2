-- Additive Conference module schema.
-- This migration does not alter or recreate the legacy conference_bookings table.
-- Guest events remain local to the existing guest session; these tables are
-- available only to authenticated owners.

BEGIN;

CREATE TABLE IF NOT EXISTS public.conference_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    conference_code VARCHAR(5) NOT NULL UNIQUE
        CHECK (conference_code ~ '^[0-9]{5}$'),
    title TEXT NOT NULL,
    slogan TEXT NOT NULL DEFAULT '',
    event_date DATE NOT NULL,
    organizer_name TEXT NOT NULL,
    organizer_email TEXT NOT NULL,
    location TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS conference_events_user_created_idx
    ON public.conference_events (user_id, created_at DESC);

CREATE TABLE IF NOT EXISTS public.conference_providers (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    category TEXT NOT NULL CHECK (
        category IN (
            'hall', 'food', 'sound', 'decoration',
            'photography', 'transportation'
        )
    ),
    city TEXT NOT NULL,
    address TEXT NOT NULL DEFAULT '',
    description TEXT NOT NULL DEFAULT '',
    image_url TEXT NOT NULL DEFAULT '',
    starting_price NUMERIC(12, 2) NOT NULL DEFAULT 0
        CHECK (starting_price >= 0),
    rating NUMERIC(3, 2),
    details JSONB NOT NULL DEFAULT '{}'::jsonb,
    is_demo BOOLEAN NOT NULL DEFAULT false,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS conference_providers_category_city_idx
    ON public.conference_providers (category, lower(city))
    WHERE is_active = true;

CREATE TABLE IF NOT EXISTS public.conference_provider_bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_code VARCHAR(10) NOT NULL UNIQUE DEFAULT
        upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 10)),
    conference_id UUID NOT NULL
        REFERENCES public.conference_events(id) ON DELETE CASCADE,
    provider_id TEXT NOT NULL
        REFERENCES public.conference_providers(id) ON DELETE RESTRICT,
    category TEXT NOT NULL CHECK (
        category IN (
            'hall', 'food', 'sound', 'decoration',
            'photography', 'transportation'
        )
    ),
    provider_name TEXT NOT NULL,
    package_name TEXT NOT NULL DEFAULT '',
    booking_date DATE NOT NULL,
    total_price NUMERIC(12, 2) NOT NULL CHECK (total_price >= 0),
    selection_details JSONB NOT NULL DEFAULT '{}'::jsonb,
    status TEXT NOT NULL DEFAULT 'pending'
        CHECK (status IN ('pending', 'confirmed', 'completed', 'cancelled')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS conference_provider_bookings_conference_idx
    ON public.conference_provider_bookings (conference_id, category);

CREATE UNIQUE INDEX IF NOT EXISTS conference_provider_bookings_active_category_unique
    ON public.conference_provider_bookings (conference_id, category)
    WHERE status <> 'cancelled';

CREATE UNIQUE INDEX IF NOT EXISTS conference_hall_booking_date_unique
    ON public.conference_provider_bookings (provider_id, booking_date)
    WHERE category = 'hall' AND status IN ('pending', 'confirmed');

CREATE OR REPLACE FUNCTION public.validate_conference_booking_status()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.status <> OLD.status AND NOT (
        (OLD.status = 'pending' AND NEW.status IN ('confirmed', 'cancelled'))
        OR (OLD.status = 'confirmed' AND NEW.status IN ('completed', 'cancelled'))
    ) THEN
        RAISE EXCEPTION 'Invalid conference booking status transition: % to %',
            OLD.status, NEW.status
            USING ERRCODE = 'check_violation';
    END IF;
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_trigger
        WHERE tgname = 'conference_booking_status_transition'
          AND tgrelid = 'public.conference_provider_bookings'::regclass
          AND NOT tgisinternal
    ) THEN
        CREATE TRIGGER conference_booking_status_transition
            BEFORE UPDATE ON public.conference_provider_bookings
            FOR EACH ROW
            EXECUTE FUNCTION public.validate_conference_booking_status();
    END IF;
END;
$$;

CREATE TABLE IF NOT EXISTS public.conference_food_orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL UNIQUE
        REFERENCES public.conference_provider_bookings(id) ON DELETE CASCADE,
    participants INTEGER NOT NULL CHECK (participants > 0),
    breakfast_total NUMERIC(12, 2) NOT NULL DEFAULT 0
        CHECK (breakfast_total >= 0),
    lunch_total NUMERIC(12, 2) NOT NULL DEFAULT 0
        CHECK (lunch_total >= 0),
    dinner_total NUMERIC(12, 2) NOT NULL DEFAULT 0
        CHECK (dinner_total >= 0),
    grand_total NUMERIC(12, 2) NOT NULL DEFAULT 0
        CHECK (grand_total >= 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE TABLE IF NOT EXISTS public.conference_food_order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL
        REFERENCES public.conference_food_orders(id) ON DELETE CASCADE,
    item_id TEXT,
    item_name TEXT NOT NULL,
    meal TEXT NOT NULL CHECK (meal IN ('breakfast', 'lunch', 'dinner')),
    unit_price NUMERIC(12, 2) NOT NULL CHECK (unit_price >= 0),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    item_total NUMERIC(12, 2) NOT NULL CHECK (item_total >= 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS conference_food_order_items_order_idx
    ON public.conference_food_order_items (order_id, meal);

CREATE TABLE IF NOT EXISTS public.conference_transport_orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL UNIQUE
        REFERENCES public.conference_provider_bookings(id) ON DELETE CASCADE,
    rental_days INTEGER NOT NULL CHECK (rental_days > 0),
    pickup_location TEXT NOT NULL,
    destination TEXT NOT NULL,
    grand_total NUMERIC(12, 2) NOT NULL CHECK (grand_total >= 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE TABLE IF NOT EXISTS public.conference_transport_vehicle_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL
        REFERENCES public.conference_transport_orders(id) ON DELETE CASCADE,
    vehicle_id TEXT,
    vehicle_name TEXT NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    rental_days INTEGER NOT NULL CHECK (rental_days > 0),
    daily_price NUMERIC(12, 2) NOT NULL CHECK (daily_price >= 0),
    item_total NUMERIC(12, 2) NOT NULL CHECK (item_total >= 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS conference_transport_vehicle_items_order_idx
    ON public.conference_transport_vehicle_items (order_id);

CREATE TABLE IF NOT EXISTS public.conference_invitations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conference_id UUID NOT NULL
        REFERENCES public.conference_events(id) ON DELETE CASCADE,
    event_date DATE NOT NULL,
    location TEXT NOT NULL,
    start_time TEXT NOT NULL,
    end_time TEXT NOT NULL,
    schedule TEXT NOT NULL DEFAULT '',
    guest_numbers TEXT[] NOT NULL DEFAULT ARRAY[]::TEXT[],
    sending_status TEXT NOT NULL DEFAULT 'draft'
        CHECK (sending_status IN ('draft', 'queued', 'sent')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE OR REPLACE FUNCTION public.save_conference_service_booking(
    p_conference_id UUID,
    p_provider_id TEXT,
    p_category TEXT,
    p_provider_name TEXT,
    p_package_name TEXT,
    p_booking_date DATE,
    p_total_price NUMERIC,
    p_selection_details JSONB
)
RETURNS SETOF public.conference_provider_bookings
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
DECLARE
    saved_booking public.conference_provider_bookings%ROWTYPE;
    food_order_id UUID;
    transport_order_id UUID;
    selection_item JSONB;
    item_quantity INTEGER;
    item_price NUMERIC(12, 2);
    item_total NUMERIC(12, 2);
    breakfast_total NUMERIC(12, 2) := 0;
    lunch_total NUMERIC(12, 2) := 0;
    dinner_total NUMERIC(12, 2) := 0;
    transport_total NUMERIC(12, 2) := 0;
    participant_count INTEGER;
    rental_day_count INTEGER;
BEGIN
    IF auth.uid() IS NULL OR NOT EXISTS (
        SELECT 1
        FROM public.conference_events event
        WHERE event.id = p_conference_id AND event.user_id = auth.uid()
    ) THEN
        RAISE EXCEPTION 'Conference ownership could not be verified.'
            USING ERRCODE = '42501';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM public.conference_providers provider
        WHERE provider.id = p_provider_id
          AND provider.category = p_category
          AND provider.is_active = true
    ) THEN
        RAISE EXCEPTION 'The selected provider is unavailable.'
            USING ERRCODE = '23503';
    END IF;

    SELECT *
    INTO saved_booking
    FROM public.conference_provider_bookings booking
    WHERE booking.conference_id = p_conference_id
      AND booking.category = p_category
      AND booking.status <> 'cancelled'
    FOR UPDATE;

    IF saved_booking.id IS NULL THEN
        INSERT INTO public.conference_provider_bookings (
            conference_id,
            provider_id,
            category,
            provider_name,
            package_name,
            booking_date,
            total_price,
            selection_details,
            status
        )
        VALUES (
            p_conference_id,
            p_provider_id,
            p_category,
            p_provider_name,
            p_package_name,
            p_booking_date,
            p_total_price,
            COALESCE(p_selection_details, '{}'::jsonb),
            'confirmed'
        )
        RETURNING * INTO saved_booking;
    ELSE
        UPDATE public.conference_provider_bookings
        SET provider_id = p_provider_id,
            provider_name = p_provider_name,
            package_name = p_package_name,
            booking_date = p_booking_date,
            total_price = p_total_price,
            selection_details = COALESCE(p_selection_details, '{}'::jsonb),
            status = 'confirmed',
            updated_at = timezone('utc'::text, now())
        WHERE id = saved_booking.id
        RETURNING * INTO saved_booking;
    END IF;

    IF p_category = 'food' THEN
        participant_count := GREATEST(
            COALESCE((p_selection_details->>'participants')::INTEGER, 1),
            1
        );
        FOR selection_item IN
            SELECT value
            FROM jsonb_array_elements(
                COALESCE(p_selection_details->'items', '[]'::jsonb)
            )
        LOOP
            item_quantity := (selection_item->>'quantity')::INTEGER;
            IF item_quantity > 0 THEN
                item_price := (selection_item->>'unit_price')::NUMERIC;
                item_total := item_price * item_quantity;
                CASE selection_item->>'meal'
                    WHEN 'breakfast' THEN breakfast_total := breakfast_total + item_total;
                    WHEN 'lunch' THEN lunch_total := lunch_total + item_total;
                    WHEN 'dinner' THEN dinner_total := dinner_total + item_total;
                    ELSE
                        RAISE EXCEPTION 'Invalid conference meal category.'
                            USING ERRCODE = 'check_violation';
                END CASE;
            END IF;
        END LOOP;

        INSERT INTO public.conference_food_orders (
            booking_id,
            participants,
            breakfast_total,
            lunch_total,
            dinner_total,
            grand_total
        )
        VALUES (
            saved_booking.id,
            participant_count,
            breakfast_total,
            lunch_total,
            dinner_total,
            breakfast_total + lunch_total + dinner_total
        )
        ON CONFLICT (booking_id) DO UPDATE
        SET participants = EXCLUDED.participants,
            breakfast_total = EXCLUDED.breakfast_total,
            lunch_total = EXCLUDED.lunch_total,
            dinner_total = EXCLUDED.dinner_total,
            grand_total = EXCLUDED.grand_total,
            updated_at = timezone('utc'::text, now())
        RETURNING id INTO food_order_id;

        DELETE FROM public.conference_food_order_items
        WHERE order_id = food_order_id;

        FOR selection_item IN
            SELECT value
            FROM jsonb_array_elements(
                COALESCE(p_selection_details->'items', '[]'::jsonb)
            )
        LOOP
            item_quantity := (selection_item->>'quantity')::INTEGER;
            IF item_quantity > 0 THEN
                item_price := (selection_item->>'unit_price')::NUMERIC;
                item_total := item_price * item_quantity;
                INSERT INTO public.conference_food_order_items (
                    order_id,
                    item_id,
                    item_name,
                    meal,
                    unit_price,
                    quantity,
                    item_total
                )
                VALUES (
                    food_order_id,
                    selection_item->>'id',
                    selection_item->>'name',
                    selection_item->>'meal',
                    item_price,
                    item_quantity,
                    item_total
                );
            END IF;
        END LOOP;

        UPDATE public.conference_provider_bookings
        SET total_price = breakfast_total + lunch_total + dinner_total
        WHERE id = saved_booking.id
        RETURNING * INTO saved_booking;
    ELSIF p_category = 'transportation' THEN
        rental_day_count := GREATEST(
            COALESCE((p_selection_details->>'rental_days')::INTEGER, 1),
            1
        );
        FOR selection_item IN
            SELECT value
            FROM jsonb_array_elements(
                COALESCE(p_selection_details->'vehicles', '[]'::jsonb)
            )
        LOOP
            item_quantity := (selection_item->>'quantity')::INTEGER;
            IF item_quantity > 0 THEN
                item_price := (selection_item->>'price_per_day')::NUMERIC;
                item_total := item_price * item_quantity *
                    COALESCE((selection_item->>'days')::INTEGER, rental_day_count);
                transport_total := transport_total + item_total;
            END IF;
        END LOOP;

        INSERT INTO public.conference_transport_orders (
            booking_id,
            rental_days,
            pickup_location,
            destination,
            grand_total
        )
        VALUES (
            saved_booking.id,
            rental_day_count,
            COALESCE(p_selection_details->>'pickup_location', ''),
            COALESCE(p_selection_details->>'destination', ''),
            transport_total
        )
        ON CONFLICT (booking_id) DO UPDATE
        SET rental_days = EXCLUDED.rental_days,
            pickup_location = EXCLUDED.pickup_location,
            destination = EXCLUDED.destination,
            grand_total = EXCLUDED.grand_total,
            updated_at = timezone('utc'::text, now())
        RETURNING id INTO transport_order_id;

        DELETE FROM public.conference_transport_vehicle_items
        WHERE order_id = transport_order_id;

        FOR selection_item IN
            SELECT value
            FROM jsonb_array_elements(
                COALESCE(p_selection_details->'vehicles', '[]'::jsonb)
            )
        LOOP
            item_quantity := (selection_item->>'quantity')::INTEGER;
            IF item_quantity > 0 THEN
                item_price := (selection_item->>'price_per_day')::NUMERIC;
                item_total := item_price * item_quantity *
                    COALESCE((selection_item->>'days')::INTEGER, rental_day_count);
                INSERT INTO public.conference_transport_vehicle_items (
                    order_id,
                    vehicle_id,
                    vehicle_name,
                    quantity,
                    rental_days,
                    daily_price,
                    item_total
                )
                VALUES (
                    transport_order_id,
                    selection_item->>'id',
                    selection_item->>'name',
                    item_quantity,
                    COALESCE((selection_item->>'days')::INTEGER, rental_day_count),
                    item_price,
                    item_total
                );
            END IF;
        END LOOP;

        UPDATE public.conference_provider_bookings
        SET total_price = transport_total
        WHERE id = saved_booking.id
        RETURNING * INTO saved_booking;
    END IF;

    RETURN NEXT saved_booking;
END;
$$;

CREATE OR REPLACE FUNCTION public.update_conference_event_date(
    p_conference_id UUID,
    p_event_date DATE
)
RETURNS public.conference_events
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public
AS $$
DECLARE
    saved_event public.conference_events%ROWTYPE;
BEGIN
    SELECT *
    INTO saved_event
    FROM public.conference_events event
    WHERE event.id = p_conference_id AND event.user_id = auth.uid()
    FOR UPDATE;

    IF saved_event.id IS NULL THEN
        RAISE EXCEPTION 'Conference ownership could not be verified.'
            USING ERRCODE = '42501';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM public.conference_provider_bookings current_hall
        JOIN public.conference_provider_bookings other_hall
          ON other_hall.provider_id = current_hall.provider_id
         AND other_hall.booking_date = p_event_date
         AND other_hall.conference_id <> p_conference_id
         AND other_hall.category = 'hall'
         AND other_hall.status IN ('pending', 'confirmed')
        WHERE current_hall.conference_id = p_conference_id
          AND current_hall.category = 'hall'
          AND current_hall.status IN ('pending', 'confirmed')
    ) THEN
        RAISE EXCEPTION 'The selected hall is unavailable on this date.'
            USING ERRCODE = '23505';
    END IF;

    UPDATE public.conference_events
    SET event_date = p_event_date,
        updated_at = timezone('utc'::text, now())
    WHERE id = p_conference_id
    RETURNING * INTO saved_event;

    UPDATE public.conference_provider_bookings
    SET booking_date = p_event_date,
        updated_at = timezone('utc'::text, now())
    WHERE conference_id = p_conference_id
      AND status IN ('pending', 'confirmed');

    RETURN saved_event;
END;
$$;

ALTER TABLE public.conference_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.conference_providers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.conference_provider_bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.conference_food_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.conference_food_order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.conference_transport_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.conference_transport_vehicle_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.conference_invitations ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public' AND tablename = 'conference_events'
          AND policyname = 'Conference owners manage their events'
    ) THEN
        CREATE POLICY "Conference owners manage their events"
            ON public.conference_events FOR ALL TO authenticated
            USING (user_id = auth.uid())
            WITH CHECK (user_id = auth.uid());
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public' AND tablename = 'conference_providers'
          AND policyname = 'Active conference providers are public'
    ) THEN
        CREATE POLICY "Active conference providers are public"
            ON public.conference_providers FOR SELECT TO anon, authenticated
            USING (is_active = true);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'conference_provider_bookings'
          AND policyname = 'Owners manage conference provider bookings'
    ) THEN
        CREATE POLICY "Owners manage conference provider bookings"
            ON public.conference_provider_bookings FOR ALL TO authenticated
            USING (
                EXISTS (
                    SELECT 1 FROM public.conference_events event
                    WHERE event.id = conference_id AND event.user_id = auth.uid()
                )
            )
            WITH CHECK (
                EXISTS (
                    SELECT 1 FROM public.conference_events event
                    WHERE event.id = conference_id AND event.user_id = auth.uid()
                )
            );
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public' AND tablename = 'conference_food_orders'
          AND policyname = 'Owners manage conference food orders'
    ) THEN
        CREATE POLICY "Owners manage conference food orders"
            ON public.conference_food_orders FOR ALL TO authenticated
            USING (
                EXISTS (
                    SELECT 1
                    FROM public.conference_provider_bookings booking
                    JOIN public.conference_events event
                      ON event.id = booking.conference_id
                    WHERE booking.id = booking_id AND event.user_id = auth.uid()
                )
            )
            WITH CHECK (
                EXISTS (
                    SELECT 1
                    FROM public.conference_provider_bookings booking
                    JOIN public.conference_events event
                      ON event.id = booking.conference_id
                    WHERE booking.id = booking_id AND event.user_id = auth.uid()
                )
            );
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'conference_food_order_items'
          AND policyname = 'Owners manage conference food order items'
    ) THEN
        CREATE POLICY "Owners manage conference food order items"
            ON public.conference_food_order_items FOR ALL TO authenticated
            USING (
                EXISTS (
                    SELECT 1
                    FROM public.conference_food_orders food_order
                    JOIN public.conference_provider_bookings booking
                      ON booking.id = food_order.booking_id
                    JOIN public.conference_events event
                      ON event.id = booking.conference_id
                    WHERE food_order.id = order_id
                      AND event.user_id = auth.uid()
                )
            )
            WITH CHECK (
                EXISTS (
                    SELECT 1
                    FROM public.conference_food_orders food_order
                    JOIN public.conference_provider_bookings booking
                      ON booking.id = food_order.booking_id
                    JOIN public.conference_events event
                      ON event.id = booking.conference_id
                    WHERE food_order.id = order_id
                      AND event.user_id = auth.uid()
                )
            );
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'conference_transport_orders'
          AND policyname = 'Owners manage conference transport orders'
    ) THEN
        CREATE POLICY "Owners manage conference transport orders"
            ON public.conference_transport_orders FOR ALL TO authenticated
            USING (
                EXISTS (
                    SELECT 1
                    FROM public.conference_provider_bookings booking
                    JOIN public.conference_events event
                      ON event.id = booking.conference_id
                    WHERE booking.id = booking_id AND event.user_id = auth.uid()
                )
            )
            WITH CHECK (
                EXISTS (
                    SELECT 1
                    FROM public.conference_provider_bookings booking
                    JOIN public.conference_events event
                      ON event.id = booking.conference_id
                    WHERE booking.id = booking_id AND event.user_id = auth.uid()
                )
            );
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'conference_transport_vehicle_items'
          AND policyname = 'Owners manage conference transport vehicle items'
    ) THEN
        CREATE POLICY "Owners manage conference transport vehicle items"
            ON public.conference_transport_vehicle_items FOR ALL TO authenticated
            USING (
                EXISTS (
                    SELECT 1
                    FROM public.conference_transport_orders transport_order
                    JOIN public.conference_provider_bookings booking
                      ON booking.id = transport_order.booking_id
                    JOIN public.conference_events event
                      ON event.id = booking.conference_id
                    WHERE transport_order.id = order_id
                      AND event.user_id = auth.uid()
                )
            )
            WITH CHECK (
                EXISTS (
                    SELECT 1
                    FROM public.conference_transport_orders transport_order
                    JOIN public.conference_provider_bookings booking
                      ON booking.id = transport_order.booking_id
                    JOIN public.conference_events event
                      ON event.id = booking.conference_id
                    WHERE transport_order.id = order_id
                      AND event.user_id = auth.uid()
                )
            );
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname = 'public'
          AND tablename = 'conference_invitations'
          AND policyname = 'Owners manage conference invitations'
    ) THEN
        CREATE POLICY "Owners manage conference invitations"
            ON public.conference_invitations FOR ALL TO authenticated
            USING (
                EXISTS (
                    SELECT 1 FROM public.conference_events event
                    WHERE event.id = conference_id AND event.user_id = auth.uid()
                )
            )
            WITH CHECK (
                EXISTS (
                    SELECT 1 FROM public.conference_events event
                    WHERE event.id = conference_id AND event.user_id = auth.uid()
                )
            );
    END IF;
END;
$$;

GRANT SELECT ON public.conference_providers TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE
    ON public.conference_events,
       public.conference_provider_bookings,
       public.conference_food_orders,
       public.conference_food_order_items,
       public.conference_transport_orders,
       public.conference_transport_vehicle_items,
       public.conference_invitations
    TO authenticated;
GRANT EXECUTE ON FUNCTION public.save_conference_service_booking(
    UUID, TEXT, TEXT, TEXT, TEXT, DATE, NUMERIC, JSONB
) TO authenticated;
GRANT EXECUTE ON FUNCTION public.update_conference_event_date(UUID, DATE)
    TO authenticated;

COMMIT;
