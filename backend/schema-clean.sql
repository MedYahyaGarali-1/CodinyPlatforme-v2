


SELECT pg_catalog.set_config('search_path', '', false);


CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;



COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';



CREATE FUNCTION public.grant_course_access_on_school_link() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

BEGIN

  -- Only trigger if school_id changed from NULL to a value

  IF OLD.school_id IS NULL AND NEW.school_id IS NOT NULL THEN

    -- Grant access to all active courses

    INSERT INTO student_course_access (student_id, course_id, access_type, granted_at)

    SELECT NEW.id, c.id, 'free', CURRENT_TIMESTAMP

    FROM courses c

    WHERE c.is_active = true

    ON CONFLICT (student_id, course_id) DO NOTHING;

  END IF;

  

  RETURN NEW;

END;

$$;


ALTER FUNCTION public.grant_course_access_on_school_link() OWNER TO postgres;


CREATE FUNCTION public.set_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.set_updated_at() OWNER TO postgres;




CREATE TABLE public.course_bookmarks (
    id integer NOT NULL,
    student_id uuid NOT NULL,
    course_id integer NOT NULL,
    page_number integer NOT NULL,
    note text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.course_bookmarks OWNER TO postgres;


CREATE SEQUENCE public.course_bookmarks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.course_bookmarks_id_seq OWNER TO postgres;


ALTER SEQUENCE public.course_bookmarks_id_seq OWNED BY public.course_bookmarks.id;



CREATE TABLE public.course_chapters (
    id integer NOT NULL,
    course_id integer NOT NULL,
    chapter_number integer NOT NULL,
    title character varying(255) NOT NULL,
    start_page integer NOT NULL,
    end_page integer NOT NULL,
    description text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.course_chapters OWNER TO postgres;


CREATE SEQUENCE public.course_chapters_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.course_chapters_id_seq OWNER TO postgres;


ALTER SEQUENCE public.course_chapters_id_seq OWNED BY public.course_chapters.id;



CREATE TABLE public.courses (
    id integer NOT NULL,
    title character varying(255) NOT NULL,
    description text,
    pdf_file_path character varying(500) NOT NULL,
    total_pages integer NOT NULL,
    price_independent numeric(10,2) DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.courses OWNER TO postgres;


CREATE SEQUENCE public.courses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.courses_id_seq OWNER TO postgres;


ALTER SEQUENCE public.courses_id_seq OWNED BY public.courses.id;



CREATE TABLE public.exam_answers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    exam_session_id uuid NOT NULL,
    question_id uuid NOT NULL,
    student_answer character varying(1),
    is_correct boolean,
    answered_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT exam_answers_student_answer_check CHECK (((student_answer)::text = ANY ((ARRAY['A'::character varying, 'B'::character varying, 'C'::character varying])::text[])))
);


ALTER TABLE public.exam_answers OWNER TO postgres;


COMMENT ON TABLE public.exam_answers IS 'Stores individual answers for each exam session';



CREATE TABLE public.exam_questions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    question_number integer NOT NULL,
    question_text text NOT NULL,
    image_url text,
    option_a text NOT NULL,
    option_b text NOT NULL,
    option_c text NOT NULL,
    correct_answer character varying(1) NOT NULL,
    category character varying(50),
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT exam_questions_correct_answer_check CHECK (((correct_answer)::text = ANY ((ARRAY['A'::character varying, 'B'::character varying, 'C'::character varying])::text[])))
);


ALTER TABLE public.exam_questions OWNER TO postgres;


COMMENT ON TABLE public.exam_questions IS 'Stores all 120 exam questions with images and correct answers';



CREATE TABLE public.exam_sessions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    student_id uuid NOT NULL,
    started_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    completed_at timestamp without time zone,
    total_questions integer DEFAULT 30,
    correct_answers integer DEFAULT 0,
    wrong_answers integer DEFAULT 0,
    score numeric(5,2),
    passed boolean,
    time_taken_seconds integer
);


ALTER TABLE public.exam_sessions OWNER TO postgres;


COMMENT ON TABLE public.exam_sessions IS 'Tracks each exam attempt by students (30 questions, 45 minutes)';



COMMENT ON COLUMN public.exam_sessions.passed IS 'TRUE if score >= 76.67% (23/30 or more correct)';



CREATE TABLE public.revenue_tracking (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    student_id uuid NOT NULL,
    school_id uuid,
    school_revenue numeric(10,2) DEFAULT 0.00,
    platform_revenue numeric(10,2) DEFAULT 0.00,
    total_amount numeric(10,2) DEFAULT 0.00,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.revenue_tracking OWNER TO postgres;


COMMENT ON TABLE public.revenue_tracking IS 'Tracks revenue split: 20 TND for school, 30 TND for platform per approved student';



COMMENT ON COLUMN public.revenue_tracking.school_revenue IS 'Revenue for the driving school (20 TND)';



COMMENT ON COLUMN public.revenue_tracking.platform_revenue IS 'Revenue for the platform (30 TND)';



COMMENT ON COLUMN public.revenue_tracking.total_amount IS 'Total amount (50 TND)';



CREATE TABLE public.school_student_requests (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    student_id uuid NOT NULL,
    school_id uuid NOT NULL,
    status character varying(20) DEFAULT 'pending'::character varying,
    requested_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    reviewed_at timestamp without time zone,
    reviewed_by uuid,
    rejection_reason text,
    school_name character varying(255),
    CONSTRAINT school_student_requests_status_check CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'approved'::character varying, 'rejected'::character varying])::text[])))
);


ALTER TABLE public.school_student_requests OWNER TO postgres;


CREATE TABLE public.schools (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    name text NOT NULL,
    total_students integer DEFAULT 0,
    total_earned integer DEFAULT 0,
    total_owed_to_platform integer DEFAULT 0,
    active boolean DEFAULT true
);


ALTER TABLE public.schools OWNER TO postgres;


CREATE TABLE public.student_course_access (
    id integer NOT NULL,
    student_id uuid NOT NULL,
    course_id integer NOT NULL,
    access_type character varying(50) NOT NULL,
    payment_date timestamp without time zone,
    payment_amount numeric(10,2),
    payment_method character varying(50),
    granted_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    expires_at timestamp without time zone,
    CONSTRAINT student_course_access_access_type_check CHECK (((access_type)::text = ANY ((ARRAY['free'::character varying, 'paid'::character varying])::text[])))
);


ALTER TABLE public.student_course_access OWNER TO postgres;


CREATE SEQUENCE public.student_course_access_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.student_course_access_id_seq OWNER TO postgres;


ALTER SEQUENCE public.student_course_access_id_seq OWNED BY public.student_course_access.id;



CREATE TABLE public.student_course_progress (
    id integer NOT NULL,
    student_id uuid NOT NULL,
    course_id integer NOT NULL,
    chapter_id integer NOT NULL,
    current_page integer NOT NULL,
    completed boolean DEFAULT false,
    time_spent integer DEFAULT 0,
    last_read_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.student_course_progress OWNER TO postgres;


CREATE SEQUENCE public.student_course_progress_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.student_course_progress_id_seq OWNER TO postgres;


ALTER SEQUENCE public.student_course_progress_id_seq OWNED BY public.student_course_progress.id;



CREATE TABLE public.student_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    student_id uuid NOT NULL,
    title text NOT NULL,
    starts_at timestamp without time zone NOT NULL,
    ends_at timestamp without time zone,
    location text,
    notes text,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.student_events OWNER TO postgres;


CREATE TABLE public.students (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    student_type text NOT NULL,
    school_id uuid,
    subscription_start timestamp without time zone,
    subscription_end timestamp without time zone,
    onboarding_complete boolean DEFAULT false,
    access_method character varying(20),
    payment_verified boolean DEFAULT false,
    subscription_status character varying(20),
    school_approval_status character varying(20),
    school_attached_at timestamp without time zone,
    school_approved_at timestamp without time zone,
    is_active boolean DEFAULT false,
    access_level character varying(20) DEFAULT 'none'::character varying,
    subscription_type character varying(20),
    CONSTRAINT students_access_level_check CHECK (((access_level)::text = ANY ((ARRAY['none'::character varying, 'limited'::character varying, 'full'::character varying])::text[]))),
    CONSTRAINT students_access_method_check CHECK (((access_method)::text = ANY ((ARRAY['independent'::character varying, 'school_linked'::character varying])::text[]))),
    CONSTRAINT students_school_approval_status_check CHECK (((school_approval_status)::text = ANY ((ARRAY['pending'::character varying, 'approved'::character varying, 'rejected'::character varying])::text[]))),
    CONSTRAINT students_student_type_check CHECK ((student_type = ANY (ARRAY['independent'::text, 'attached_to_school'::text]))),
    CONSTRAINT students_subscription_status_check CHECK (((subscription_status)::text = ANY ((ARRAY['active'::character varying, 'expired'::character varying, 'cancelled'::character varying])::text[]))),
    CONSTRAINT students_subscription_type_check CHECK (((subscription_type)::text = ANY ((ARRAY['monthly'::character varying, 'yearly'::character varying, 'lifetime'::character varying])::text[])))
);


ALTER TABLE public.students OWNER TO postgres;


COMMENT ON COLUMN public.students.onboarding_complete IS 'Whether student has completed the onboarding flow';



COMMENT ON COLUMN public.students.access_method IS 'How student accesses platform: independent (paid) or school_linked (free with approval)';



COMMENT ON COLUMN public.students.payment_verified IS 'Whether student has verified payment for independent access';



COMMENT ON COLUMN public.students.school_approval_status IS 'Approval status from school: pending, approved, or rejected';



COMMENT ON COLUMN public.students.access_level IS 'Current access level: none, limited (can see dashboard), or full (all content)';



CREATE TABLE public.subscriptions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    student_id uuid,
    start_date timestamp without time zone NOT NULL,
    end_date timestamp without time zone NOT NULL,
    platform_cut integer NOT NULL,
    school_cut integer NOT NULL,
    payment_source text NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    CONSTRAINT subscriptions_payment_source_check CHECK ((payment_source = ANY (ARRAY['independent'::text, 'school'::text])))
);


ALTER TABLE public.subscriptions OWNER TO postgres;


CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    identifier text NOT NULL,
    password_hash text NOT NULL,
    role text NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    CONSTRAINT users_role_check CHECK ((role = ANY (ARRAY['student'::text, 'school'::text, 'admin'::text])))
);


ALTER TABLE public.users OWNER TO postgres;


ALTER TABLE ONLY public.course_bookmarks ALTER COLUMN id SET DEFAULT nextval('public.course_bookmarks_id_seq'::regclass);



ALTER TABLE ONLY public.course_chapters ALTER COLUMN id SET DEFAULT nextval('public.course_chapters_id_seq'::regclass);



ALTER TABLE ONLY public.courses ALTER COLUMN id SET DEFAULT nextval('public.courses_id_seq'::regclass);



ALTER TABLE ONLY public.student_course_access ALTER COLUMN id SET DEFAULT nextval('public.student_course_access_id_seq'::regclass);



ALTER TABLE ONLY public.student_course_progress ALTER COLUMN id SET DEFAULT nextval('public.student_course_progress_id_seq'::regclass);



ALTER TABLE ONLY public.course_bookmarks
    ADD CONSTRAINT course_bookmarks_pkey PRIMARY KEY (id);



ALTER TABLE ONLY public.course_chapters
    ADD CONSTRAINT course_chapters_course_id_chapter_number_key UNIQUE (course_id, chapter_number);



ALTER TABLE ONLY public.course_chapters
    ADD CONSTRAINT course_chapters_pkey PRIMARY KEY (id);



ALTER TABLE ONLY public.courses
    ADD CONSTRAINT courses_pkey PRIMARY KEY (id);



ALTER TABLE ONLY public.exam_answers
    ADD CONSTRAINT exam_answers_pkey PRIMARY KEY (id);



ALTER TABLE ONLY public.exam_questions
    ADD CONSTRAINT exam_questions_pkey PRIMARY KEY (id);



ALTER TABLE ONLY public.exam_sessions
    ADD CONSTRAINT exam_sessions_pkey PRIMARY KEY (id);



ALTER TABLE ONLY public.revenue_tracking
    ADD CONSTRAINT revenue_tracking_pkey PRIMARY KEY (id);



ALTER TABLE ONLY public.school_student_requests
    ADD CONSTRAINT school_student_requests_pkey PRIMARY KEY (id);



ALTER TABLE ONLY public.schools
    ADD CONSTRAINT schools_pkey PRIMARY KEY (id);



ALTER TABLE ONLY public.schools
    ADD CONSTRAINT schools_user_id_key UNIQUE (user_id);



ALTER TABLE ONLY public.student_course_access
    ADD CONSTRAINT student_course_access_pkey PRIMARY KEY (id);



ALTER TABLE ONLY public.student_course_access
    ADD CONSTRAINT student_course_access_student_id_course_id_key UNIQUE (student_id, course_id);



ALTER TABLE ONLY public.student_course_progress
    ADD CONSTRAINT student_course_progress_pkey PRIMARY KEY (id);



ALTER TABLE ONLY public.student_course_progress
    ADD CONSTRAINT student_course_progress_student_id_course_id_chapter_id_key UNIQUE (student_id, course_id, chapter_id);



ALTER TABLE ONLY public.student_events
    ADD CONSTRAINT student_events_pkey PRIMARY KEY (id);



ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_pkey PRIMARY KEY (id);



ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_user_id_key UNIQUE (user_id);



ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (id);



ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_identifier_key UNIQUE (identifier);



ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);



CREATE INDEX idx_bookmarks_course ON public.course_bookmarks USING btree (course_id);



CREATE INDEX idx_bookmarks_student ON public.course_bookmarks USING btree (student_id);



CREATE INDEX idx_course_chapters_course ON public.course_chapters USING btree (course_id);



CREATE INDEX idx_exam_answers_correct ON public.exam_answers USING btree (is_correct);



CREATE INDEX idx_exam_answers_question ON public.exam_answers USING btree (question_id);



CREATE INDEX idx_exam_answers_session ON public.exam_answers USING btree (exam_session_id);



CREATE INDEX idx_exam_questions_active ON public.exam_questions USING btree (is_active);



CREATE INDEX idx_exam_questions_category ON public.exam_questions USING btree (category);



CREATE INDEX idx_exam_questions_created ON public.exam_questions USING btree (created_at);



CREATE INDEX idx_exam_questions_number ON public.exam_questions USING btree (question_number);



CREATE INDEX idx_exam_sessions_completed ON public.exam_sessions USING btree (completed_at);



CREATE INDEX idx_exam_sessions_passed ON public.exam_sessions USING btree (passed);



CREATE INDEX idx_exam_sessions_score ON public.exam_sessions USING btree (score);



CREATE INDEX idx_exam_sessions_started ON public.exam_sessions USING btree (started_at DESC);



CREATE INDEX idx_exam_sessions_student ON public.exam_sessions USING btree (student_id);



CREATE INDEX idx_exam_sessions_student_completed ON public.exam_sessions USING btree (student_id, completed_at DESC);



CREATE INDEX idx_revenue_created ON public.revenue_tracking USING btree (created_at);



CREATE INDEX idx_revenue_school ON public.revenue_tracking USING btree (school_id);



CREATE INDEX idx_revenue_student ON public.revenue_tracking USING btree (student_id);



CREATE INDEX idx_school_requests_school ON public.school_student_requests USING btree (school_id, status);



CREATE INDEX idx_school_requests_status ON public.school_student_requests USING btree (status);



CREATE INDEX idx_schools_name ON public.schools USING btree (name);



CREATE INDEX idx_student_access_course ON public.student_course_access USING btree (course_id);



CREATE INDEX idx_student_access_student ON public.student_course_access USING btree (student_id);



CREATE INDEX idx_student_events_starts_at ON public.student_events USING btree (starts_at);



CREATE INDEX idx_student_events_student_id ON public.student_events USING btree (student_id);



CREATE INDEX idx_student_progress_course ON public.student_course_progress USING btree (course_id);



CREATE INDEX idx_student_progress_student ON public.student_course_progress USING btree (student_id);



CREATE INDEX idx_students_access_method ON public.students USING btree (access_method);



CREATE INDEX idx_students_is_active ON public.students USING btree (is_active);



CREATE INDEX idx_students_onboarding ON public.students USING btree (onboarding_complete);



CREATE INDEX idx_students_payment_verified ON public.students USING btree (payment_verified);



CREATE INDEX idx_students_school_approval_status ON public.students USING btree (school_approval_status);



CREATE INDEX idx_students_school_id ON public.students USING btree (school_id);



CREATE INDEX idx_students_school_status ON public.students USING btree (school_id, school_approval_status);



CREATE INDEX idx_students_subscription_status ON public.students USING btree (subscription_status);



CREATE INDEX idx_students_type ON public.students USING btree (student_type);



CREATE INDEX idx_students_user_id ON public.students USING btree (user_id);



CREATE INDEX idx_users_created_at ON public.users USING btree (created_at);



CREATE INDEX idx_users_identifier ON public.users USING btree (identifier);



CREATE INDEX idx_users_role ON public.users USING btree (role);



CREATE TRIGGER trg_student_events_updated_at BEFORE UPDATE ON public.student_events FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();



CREATE TRIGGER trigger_grant_course_access AFTER UPDATE OF school_id ON public.students FOR EACH ROW EXECUTE FUNCTION public.grant_course_access_on_school_link();



ALTER TABLE ONLY public.course_bookmarks
    ADD CONSTRAINT course_bookmarks_course_id_fkey FOREIGN KEY (course_id) REFERENCES public.courses(id) ON DELETE CASCADE;



ALTER TABLE ONLY public.course_bookmarks
    ADD CONSTRAINT course_bookmarks_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.students(id) ON DELETE CASCADE;



ALTER TABLE ONLY public.course_chapters
    ADD CONSTRAINT course_chapters_course_id_fkey FOREIGN KEY (course_id) REFERENCES public.courses(id) ON DELETE CASCADE;



ALTER TABLE ONLY public.exam_answers
    ADD CONSTRAINT fk_answer_question FOREIGN KEY (question_id) REFERENCES public.exam_questions(id) ON DELETE CASCADE;



ALTER TABLE ONLY public.exam_answers
    ADD CONSTRAINT fk_answer_session FOREIGN KEY (exam_session_id) REFERENCES public.exam_sessions(id) ON DELETE CASCADE;



ALTER TABLE ONLY public.exam_sessions
    ADD CONSTRAINT fk_exam_student FOREIGN KEY (student_id) REFERENCES public.students(id) ON DELETE CASCADE;



ALTER TABLE ONLY public.school_student_requests
    ADD CONSTRAINT fk_request_student FOREIGN KEY (student_id) REFERENCES public.students(id) ON DELETE CASCADE;



ALTER TABLE ONLY public.revenue_tracking
    ADD CONSTRAINT fk_revenue_student FOREIGN KEY (student_id) REFERENCES public.students(id) ON DELETE CASCADE;



ALTER TABLE ONLY public.schools
    ADD CONSTRAINT schools_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;



ALTER TABLE ONLY public.student_course_access
    ADD CONSTRAINT student_course_access_course_id_fkey FOREIGN KEY (course_id) REFERENCES public.courses(id) ON DELETE CASCADE;



ALTER TABLE ONLY public.student_course_access
    ADD CONSTRAINT student_course_access_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.students(id) ON DELETE CASCADE;



ALTER TABLE ONLY public.student_course_progress
    ADD CONSTRAINT student_course_progress_chapter_id_fkey FOREIGN KEY (chapter_id) REFERENCES public.course_chapters(id) ON DELETE CASCADE;



ALTER TABLE ONLY public.student_course_progress
    ADD CONSTRAINT student_course_progress_course_id_fkey FOREIGN KEY (course_id) REFERENCES public.courses(id) ON DELETE CASCADE;



ALTER TABLE ONLY public.student_course_progress
    ADD CONSTRAINT student_course_progress_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.students(id) ON DELETE CASCADE;



ALTER TABLE ONLY public.student_events
    ADD CONSTRAINT student_events_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.students(id) ON DELETE CASCADE;



ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;



ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.students(id) ON DELETE CASCADE;




