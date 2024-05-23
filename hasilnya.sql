--
-- PostgreSQL database dump
--

-- Dumped from database version 15.1
-- Dumped by pg_dump version 15.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: hotel; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA hotel;


ALTER SCHEMA hotel OWNER TO postgres;

--
-- Name: master; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA master;


ALTER SCHEMA master OWNER TO postgres;

--
-- Name: users; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA users;


ALTER SCHEMA users OWNER TO postgres;

--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


--
-- Name: update_hotel_rating_star(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_hotel_rating_star() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  avg_rating NUMERIC;
BEGIN
  SELECT AVG(hore_rating) INTO avg_rating FROM hotel.hotel_reviews WHERE hore_hotel_id = NEW.hore_hotel_id;
  UPDATE hotel.hotels SET hotel_rating_star = avg_rating WHERE hotel_id = NEW.hore_hotel_id;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_hotel_rating_star() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: facilities; Type: TABLE; Schema: hotel; Owner: postgres
--

CREATE TABLE hotel.facilities (
    faci_id integer NOT NULL,
    faci_name character varying(125),
    faci_description character varying(255),
    faci_max_number integer,
    faci_measure_unit character varying(15),
    faci_room_number character varying(6),
    faci_startdate timestamp without time zone,
    faci_enddate timestamp without time zone,
    faci_low_price money,
    faci_high_price money,
    faci_rate_price money,
    faci_discount money,
    faci_tax_rate money,
    faci_cagro_id integer,
    faci_hotel_id integer,
    faci_modified_date timestamp without time zone DEFAULT now(),
    CONSTRAINT facilities_faci_measure_unit_check CHECK (((faci_measure_unit)::text = ANY ((ARRAY['people'::character varying, 'beds'::character varying])::text[])))
);


ALTER TABLE hotel.facilities OWNER TO postgres;

--
-- Name: facilities_faci_id_seq; Type: SEQUENCE; Schema: hotel; Owner: postgres
--

CREATE SEQUENCE hotel.facilities_faci_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE hotel.facilities_faci_id_seq OWNER TO postgres;

--
-- Name: facilities_faci_id_seq; Type: SEQUENCE OWNED BY; Schema: hotel; Owner: postgres
--

ALTER SEQUENCE hotel.facilities_faci_id_seq OWNED BY hotel.facilities.faci_id;


--
-- Name: facility_photos; Type: TABLE; Schema: hotel; Owner: postgres
--

CREATE TABLE hotel.facility_photos (
    fapho_id integer NOT NULL,
    fapho_faci_id integer,
    fapho_thumbnail_filename character varying(50),
    fapho_photo_filename character varying(50),
    fapho_primary boolean,
    fapho_modified_date timestamp without time zone DEFAULT now()
);


ALTER TABLE hotel.facility_photos OWNER TO postgres;

--
-- Name: facility_photos_fapho_id_seq; Type: SEQUENCE; Schema: hotel; Owner: postgres
--

CREATE SEQUENCE hotel.facility_photos_fapho_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE hotel.facility_photos_fapho_id_seq OWNER TO postgres;

--
-- Name: facility_photos_fapho_id_seq; Type: SEQUENCE OWNED BY; Schema: hotel; Owner: postgres
--

ALTER SEQUENCE hotel.facility_photos_fapho_id_seq OWNED BY hotel.facility_photos.fapho_id;


--
-- Name: facility_price_history; Type: TABLE; Schema: hotel; Owner: postgres
--

CREATE TABLE hotel.facility_price_history (
    faph_id integer NOT NULL,
    faph_startdate timestamp without time zone,
    faph_enddate timestamp without time zone,
    faph_low_price money,
    faph_high_price money,
    faph_rate_price money,
    faph_discount money,
    faph_tax_rate money,
    faph_modified_date timestamp without time zone DEFAULT now(),
    faph_user_id integer,
    faph_faci_id integer
);


ALTER TABLE hotel.facility_price_history OWNER TO postgres;

--
-- Name: facility_price_history_faph_id_seq; Type: SEQUENCE; Schema: hotel; Owner: postgres
--

CREATE SEQUENCE hotel.facility_price_history_faph_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE hotel.facility_price_history_faph_id_seq OWNER TO postgres;

--
-- Name: facility_price_history_faph_id_seq; Type: SEQUENCE OWNED BY; Schema: hotel; Owner: postgres
--

ALTER SEQUENCE hotel.facility_price_history_faph_id_seq OWNED BY hotel.facility_price_history.faph_id;


--
-- Name: hotel_reviews; Type: TABLE; Schema: hotel; Owner: postgres
--

CREATE TABLE hotel.hotel_reviews (
    hore_id integer NOT NULL,
    hore_user_review character varying(125),
    hore_rating smallint,
    hore_created_on timestamp without time zone DEFAULT now(),
    hore_user_id integer,
    hore_hotel_id integer,
    CONSTRAINT hotel_reviews_hore_rating_check CHECK ((hore_rating = ANY (ARRAY[1, 2, 3, 4, 5])))
);


ALTER TABLE hotel.hotel_reviews OWNER TO postgres;

--
-- Name: hotel_reviews_hore_id_seq; Type: SEQUENCE; Schema: hotel; Owner: postgres
--

CREATE SEQUENCE hotel.hotel_reviews_hore_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE hotel.hotel_reviews_hore_id_seq OWNER TO postgres;

--
-- Name: hotel_reviews_hore_id_seq; Type: SEQUENCE OWNED BY; Schema: hotel; Owner: postgres
--

ALTER SEQUENCE hotel.hotel_reviews_hore_id_seq OWNED BY hotel.hotel_reviews.hore_id;


--
-- Name: hotels; Type: TABLE; Schema: hotel; Owner: postgres
--

CREATE TABLE hotel.hotels (
    hotel_id integer NOT NULL,
    hotel_name character varying(85),
    hotel_description character varying(500),
    hotel_rating_star numeric,
    hotel_phonenumber character varying(25),
    status character varying(10) NOT NULL,
    reason character varying(100),
    hotel_addr_id integer,
    hotel_modified_date timestamp without time zone DEFAULT now(),
    CONSTRAINT hotels_status_check CHECK (((status)::text = ANY ((ARRAY['active'::character varying, 'disactive'::character varying])::text[])))
);


ALTER TABLE hotel.hotels OWNER TO postgres;

--
-- Name: hotels_hotel_id_seq; Type: SEQUENCE; Schema: hotel; Owner: postgres
--

CREATE SEQUENCE hotel.hotels_hotel_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE hotel.hotels_hotel_id_seq OWNER TO postgres;

--
-- Name: hotels_hotel_id_seq; Type: SEQUENCE OWNED BY; Schema: hotel; Owner: postgres
--

ALTER SEQUENCE hotel.hotels_hotel_id_seq OWNED BY hotel.hotels.hotel_id;


--
-- Name: address; Type: TABLE; Schema: master; Owner: postgres
--

CREATE TABLE master.address (
    addr_id integer NOT NULL,
    addr_line1 character varying(225),
    addr_line2 character varying(225),
    addr_postal_code character varying(5),
    addr_spatial_location public.geography,
    addr_prov_id integer
);


ALTER TABLE master.address OWNER TO postgres;

--
-- Name: address_addr_id_seq; Type: SEQUENCE; Schema: master; Owner: postgres
--

CREATE SEQUENCE master.address_addr_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE master.address_addr_id_seq OWNER TO postgres;

--
-- Name: address_addr_id_seq; Type: SEQUENCE OWNED BY; Schema: master; Owner: postgres
--

ALTER SEQUENCE master.address_addr_id_seq OWNED BY master.address.addr_id;


--
-- Name: category_group; Type: TABLE; Schema: master; Owner: postgres
--

CREATE TABLE master.category_group (
    cagro_id integer NOT NULL,
    cagro_name character varying(25),
    cagro_description character varying(255),
    cagro_type character varying(25),
    cagro_icon character varying(255),
    cagro_icon_url character varying(255),
    CONSTRAINT category_group_cagro_type_check CHECK (((cagro_type)::text = ANY ((ARRAY['category'::character varying, 'service'::character varying, 'facility'::character varying])::text[])))
);


ALTER TABLE master.category_group OWNER TO postgres;

--
-- Name: category_group_cagro_id_seq; Type: SEQUENCE; Schema: master; Owner: postgres
--

CREATE SEQUENCE master.category_group_cagro_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE master.category_group_cagro_id_seq OWNER TO postgres;

--
-- Name: category_group_cagro_id_seq; Type: SEQUENCE OWNED BY; Schema: master; Owner: postgres
--

ALTER SEQUENCE master.category_group_cagro_id_seq OWNED BY master.category_group.cagro_id;


--
-- Name: country; Type: TABLE; Schema: master; Owner: postgres
--

CREATE TABLE master.country (
    country_id integer NOT NULL,
    country_name character varying(55),
    country_region_id integer
);


ALTER TABLE master.country OWNER TO postgres;

--
-- Name: country_country_id_seq; Type: SEQUENCE; Schema: master; Owner: postgres
--

CREATE SEQUENCE master.country_country_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE master.country_country_id_seq OWNER TO postgres;

--
-- Name: country_country_id_seq; Type: SEQUENCE OWNED BY; Schema: master; Owner: postgres
--

ALTER SEQUENCE master.country_country_id_seq OWNED BY master.country.country_id;


--
-- Name: policy; Type: TABLE; Schema: master; Owner: postgres
--

CREATE TABLE master.policy (
    poli_id integer NOT NULL,
    poli_name character varying(55),
    poli_description character varying(255)
);


ALTER TABLE master.policy OWNER TO postgres;

--
-- Name: policy_category_group; Type: TABLE; Schema: master; Owner: postgres
--

CREATE TABLE master.policy_category_group (
    poca_poli_id integer NOT NULL,
    poca_cagro_id integer NOT NULL
);


ALTER TABLE master.policy_category_group OWNER TO postgres;

--
-- Name: policy_poli_id_seq; Type: SEQUENCE; Schema: master; Owner: postgres
--

CREATE SEQUENCE master.policy_poli_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE master.policy_poli_id_seq OWNER TO postgres;

--
-- Name: policy_poli_id_seq; Type: SEQUENCE OWNED BY; Schema: master; Owner: postgres
--

ALTER SEQUENCE master.policy_poli_id_seq OWNED BY master.policy.poli_id;


--
-- Name: provinces; Type: TABLE; Schema: master; Owner: postgres
--

CREATE TABLE master.provinces (
    prov_id integer NOT NULL,
    prov_name character varying(85),
    prov_country_id integer
);


ALTER TABLE master.provinces OWNER TO postgres;

--
-- Name: provinces_prov_id_seq; Type: SEQUENCE; Schema: master; Owner: postgres
--

CREATE SEQUENCE master.provinces_prov_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE master.provinces_prov_id_seq OWNER TO postgres;

--
-- Name: provinces_prov_id_seq; Type: SEQUENCE OWNED BY; Schema: master; Owner: postgres
--

ALTER SEQUENCE master.provinces_prov_id_seq OWNED BY master.provinces.prov_id;


--
-- Name: regions; Type: TABLE; Schema: master; Owner: postgres
--

CREATE TABLE master.regions (
    region_code integer NOT NULL,
    region_name character varying(35)
);


ALTER TABLE master.regions OWNER TO postgres;

--
-- Name: regions_region_code_seq; Type: SEQUENCE; Schema: master; Owner: postgres
--

CREATE SEQUENCE master.regions_region_code_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE master.regions_region_code_seq OWNER TO postgres;

--
-- Name: regions_region_code_seq; Type: SEQUENCE OWNED BY; Schema: master; Owner: postgres
--

ALTER SEQUENCE master.regions_region_code_seq OWNED BY master.regions.region_code;


--
-- Name: sequence_for_user_full_name; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sequence_for_user_full_name
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sequence_for_user_full_name OWNER TO postgres;

--
-- Name: tes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tes (
);


ALTER TABLE public.tes OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: users; Owner: postgres
--

CREATE TABLE users.users (
    user_id integer NOT NULL,
    user_full_name character varying DEFAULT ('guest'::text || nextval('public.sequence_for_user_full_name'::regclass)),
    user_type character varying(15) NOT NULL,
    user_company_name character varying(225),
    user_email character varying(256),
    user_phone_number character varying(25),
    user_modified_date timestamp without time zone,
    user_photo_profile character varying(225),
    user_hotel_id integer
);


ALTER TABLE users.users OWNER TO postgres;

--
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: users; Owner: postgres
--

ALTER TABLE users.users ALTER COLUMN user_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME users.users_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: facilities faci_id; Type: DEFAULT; Schema: hotel; Owner: postgres
--

ALTER TABLE ONLY hotel.facilities ALTER COLUMN faci_id SET DEFAULT nextval('hotel.facilities_faci_id_seq'::regclass);


--
-- Name: facility_photos fapho_id; Type: DEFAULT; Schema: hotel; Owner: postgres
--

ALTER TABLE ONLY hotel.facility_photos ALTER COLUMN fapho_id SET DEFAULT nextval('hotel.facility_photos_fapho_id_seq'::regclass);


--
-- Name: facility_price_history faph_id; Type: DEFAULT; Schema: hotel; Owner: postgres
--

ALTER TABLE ONLY hotel.facility_price_history ALTER COLUMN faph_id SET DEFAULT nextval('hotel.facility_price_history_faph_id_seq'::regclass);


--
-- Name: hotel_reviews hore_id; Type: DEFAULT; Schema: hotel; Owner: postgres
--

ALTER TABLE ONLY hotel.hotel_reviews ALTER COLUMN hore_id SET DEFAULT nextval('hotel.hotel_reviews_hore_id_seq'::regclass);


--
-- Name: hotels hotel_id; Type: DEFAULT; Schema: hotel; Owner: postgres
--

ALTER TABLE ONLY hotel.hotels ALTER COLUMN hotel_id SET DEFAULT nextval('hotel.hotels_hotel_id_seq'::regclass);


--
-- Name: address addr_id; Type: DEFAULT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY master.address ALTER COLUMN addr_id SET DEFAULT nextval('master.address_addr_id_seq'::regclass);


--
-- Name: category_group cagro_id; Type: DEFAULT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY master.category_group ALTER COLUMN cagro_id SET DEFAULT nextval('master.category_group_cagro_id_seq'::regclass);


--
-- Name: country country_id; Type: DEFAULT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY master.country ALTER COLUMN country_id SET DEFAULT nextval('master.country_country_id_seq'::regclass);


--
-- Name: policy poli_id; Type: DEFAULT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY master.policy ALTER COLUMN poli_id SET DEFAULT nextval('master.policy_poli_id_seq'::regclass);


--
-- Name: provinces prov_id; Type: DEFAULT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY master.provinces ALTER COLUMN prov_id SET DEFAULT nextval('master.provinces_prov_id_seq'::regclass);


--
-- Name: regions region_code; Type: DEFAULT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY master.regions ALTER COLUMN region_code SET DEFAULT nextval('master.regions_region_code_seq'::regclass);


--
-- Data for Name: facilities; Type: TABLE DATA; Schema: hotel; Owner: postgres
--

COPY hotel.facilities (faci_id, faci_name, faci_description, faci_max_number, faci_measure_unit, faci_room_number, faci_startdate, faci_enddate, faci_low_price, faci_high_price, faci_rate_price, faci_discount, faci_tax_rate, faci_cagro_id, faci_hotel_id, faci_modified_date) FROM stdin;
45	kasur	kasurnya bagus buat yang capek bgt sama hidup	1	beds	127	2022-01-01 01:00:00	2022-12-31 10:00:00	$100,000.00	$500,000.00	$250,000.00	$5.00	$10.00	2	9	2023-03-26 15:22:33.877184
\.


--
-- Data for Name: facility_photos; Type: TABLE DATA; Schema: hotel; Owner: postgres
--

COPY hotel.facility_photos (fapho_id, fapho_faci_id, fapho_thumbnail_filename, fapho_photo_filename, fapho_primary, fapho_modified_date) FROM stdin;
\.


--
-- Data for Name: facility_price_history; Type: TABLE DATA; Schema: hotel; Owner: postgres
--

COPY hotel.facility_price_history (faph_id, faph_startdate, faph_enddate, faph_low_price, faph_high_price, faph_rate_price, faph_discount, faph_tax_rate, faph_modified_date, faph_user_id, faph_faci_id) FROM stdin;
\.


--
-- Data for Name: hotel_reviews; Type: TABLE DATA; Schema: hotel; Owner: postgres
--

COPY hotel.hotel_reviews (hore_id, hore_user_review, hore_rating, hore_created_on, hore_user_id, hore_hotel_id) FROM stdin;
9	bantalnya bau jigong	2	2023-03-26 15:00:08.571804	1	8
10	mantap murmer!	5	2023-03-26 15:00:39.232142	1	8
11	alhamdulillah buka puasa di hotel ini nyaman	5	2023-03-26 15:01:38.222598	1	9
12	keren parkirnya gratis	4	2023-03-26 15:02:14.208466	1	9
18	jelek banget hotelnya, jorokk, bantalnya bau jigong	1	2023-03-26 15:07:17.501984	1	9
\.


--
-- Data for Name: hotels; Type: TABLE DATA; Schema: hotel; Owner: postgres
--

COPY hotel.hotels (hotel_id, hotel_name, hotel_description, hotel_rating_star, hotel_phonenumber, status, reason, hotel_addr_id, hotel_modified_date) FROM stdin;
8	mawar	hotel halal	3.5000000000000000	082297760332	active	\N	1	2023-03-26 14:59:42.656641
9	mawar	hotel halal	3.3333333333333333	082297760332	active	\N	1	2023-03-26 15:01:05.495167
\.


--
-- Data for Name: address; Type: TABLE DATA; Schema: master; Owner: postgres
--

COPY master.address (addr_id, addr_line1, addr_line2, addr_postal_code, addr_spatial_location, addr_prov_id) FROM stdin;
1	123 Main St	Apt 4B	10001	0101000020E6100000B3EA73B5157F52C0C7293A92CB5F4440	1
2	456 Elm St	\N	90210	0101000020E6100000BC749318049A5DC0EC51B81E850B4140	2
3	789 Oak St	Unit 7	60601	0101000020E610000055C1A8A44EE855C00E4FAF9465F04440	3
\.


--
-- Data for Name: category_group; Type: TABLE DATA; Schema: master; Owner: postgres
--

COPY master.category_group (cagro_id, cagro_name, cagro_description, cagro_type, cagro_icon, cagro_icon_url) FROM stdin;
1	Food	Food items	category	icon.png	http://example.com/icon.png
2	Facility	Facility items	facility	icon.png	http://example.com/icon.png
\.


--
-- Data for Name: country; Type: TABLE DATA; Schema: master; Owner: postgres
--

COPY master.country (country_id, country_name, country_region_id) FROM stdin;
1	Canada	1
2	United States	1
\.


--
-- Data for Name: policy; Type: TABLE DATA; Schema: master; Owner: postgres
--

COPY master.policy (poli_id, poli_name, poli_description) FROM stdin;
1	Privacy Policy	Our privacy policy
2	Terms of Service	Our terms of service
\.


--
-- Data for Name: policy_category_group; Type: TABLE DATA; Schema: master; Owner: postgres
--

COPY master.policy_category_group (poca_poli_id, poca_cagro_id) FROM stdin;
1	1
2	2
\.


--
-- Data for Name: provinces; Type: TABLE DATA; Schema: master; Owner: postgres
--

COPY master.provinces (prov_id, prov_name, prov_country_id) FROM stdin;
1	Ontario	1
2	California	2
3	Illinois	2
\.


--
-- Data for Name: regions; Type: TABLE DATA; Schema: master; Owner: postgres
--

COPY master.regions (region_code, region_name) FROM stdin;
1	North America
\.


--
-- Data for Name: spatial_ref_sys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.spatial_ref_sys (srid, auth_name, auth_srid, srtext, proj4text) FROM stdin;
\.


--
-- Data for Name: tes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tes  FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: users; Owner: postgres
--

COPY users.users (user_id, user_full_name, user_type, user_company_name, user_email, user_phone_number, user_modified_date, user_photo_profile, user_hotel_id) FROM stdin;
1	Rifqi Pratama	T	CodeX	mail@gmail.com	082132184219	2023-01-01 16:10:55	dhsads.jpg	1
\.


--
-- Name: facilities_faci_id_seq; Type: SEQUENCE SET; Schema: hotel; Owner: postgres
--

SELECT pg_catalog.setval('hotel.facilities_faci_id_seq', 45, true);


--
-- Name: facility_photos_fapho_id_seq; Type: SEQUENCE SET; Schema: hotel; Owner: postgres
--

SELECT pg_catalog.setval('hotel.facility_photos_fapho_id_seq', 27, true);


--
-- Name: facility_price_history_faph_id_seq; Type: SEQUENCE SET; Schema: hotel; Owner: postgres
--

SELECT pg_catalog.setval('hotel.facility_price_history_faph_id_seq', 30, true);


--
-- Name: hotel_reviews_hore_id_seq; Type: SEQUENCE SET; Schema: hotel; Owner: postgres
--

SELECT pg_catalog.setval('hotel.hotel_reviews_hore_id_seq', 18, true);


--
-- Name: hotels_hotel_id_seq; Type: SEQUENCE SET; Schema: hotel; Owner: postgres
--

SELECT pg_catalog.setval('hotel.hotels_hotel_id_seq', 9, true);


--
-- Name: address_addr_id_seq; Type: SEQUENCE SET; Schema: master; Owner: postgres
--

SELECT pg_catalog.setval('master.address_addr_id_seq', 3, true);


--
-- Name: category_group_cagro_id_seq; Type: SEQUENCE SET; Schema: master; Owner: postgres
--

SELECT pg_catalog.setval('master.category_group_cagro_id_seq', 3, true);


--
-- Name: country_country_id_seq; Type: SEQUENCE SET; Schema: master; Owner: postgres
--

SELECT pg_catalog.setval('master.country_country_id_seq', 2, true);


--
-- Name: policy_poli_id_seq; Type: SEQUENCE SET; Schema: master; Owner: postgres
--

SELECT pg_catalog.setval('master.policy_poli_id_seq', 2, true);


--
-- Name: provinces_prov_id_seq; Type: SEQUENCE SET; Schema: master; Owner: postgres
--

SELECT pg_catalog.setval('master.provinces_prov_id_seq', 3, true);


--
-- Name: regions_region_code_seq; Type: SEQUENCE SET; Schema: master; Owner: postgres
--

SELECT pg_catalog.setval('master.regions_region_code_seq', 1, true);


--
-- Name: sequence_for_user_full_name; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sequence_for_user_full_name', 1, false);


--
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: users; Owner: postgres
--

SELECT pg_catalog.setval('users.users_user_id_seq', 1, true);


--
-- Name: facilities facilities_faci_room_number_key; Type: CONSTRAINT; Schema: hotel; Owner: postgres
--

ALTER TABLE ONLY hotel.facilities
    ADD CONSTRAINT facilities_faci_room_number_key UNIQUE (faci_room_number);


--
-- Name: facilities facilities_pkey; Type: CONSTRAINT; Schema: hotel; Owner: postgres
--

ALTER TABLE ONLY hotel.facilities
    ADD CONSTRAINT facilities_pkey PRIMARY KEY (faci_id);


--
-- Name: facility_photos facility_photos_pkey; Type: CONSTRAINT; Schema: hotel; Owner: postgres
--

ALTER TABLE ONLY hotel.facility_photos
    ADD CONSTRAINT facility_photos_pkey PRIMARY KEY (fapho_id);


--
-- Name: facility_price_history facility_price_history_pkey; Type: CONSTRAINT; Schema: hotel; Owner: postgres
--

ALTER TABLE ONLY hotel.facility_price_history
    ADD CONSTRAINT facility_price_history_pkey PRIMARY KEY (faph_id);


--
-- Name: hotel_reviews hotel_reviews_pkey; Type: CONSTRAINT; Schema: hotel; Owner: postgres
--

ALTER TABLE ONLY hotel.hotel_reviews
    ADD CONSTRAINT hotel_reviews_pkey PRIMARY KEY (hore_id);


--
-- Name: hotels hotels_pkey; Type: CONSTRAINT; Schema: hotel; Owner: postgres
--

ALTER TABLE ONLY hotel.hotels
    ADD CONSTRAINT hotels_pkey PRIMARY KEY (hotel_id);


--
-- Name: address address_pkey; Type: CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY master.address
    ADD CONSTRAINT address_pkey PRIMARY KEY (addr_id);


--
-- Name: category_group category_group_cagro_name_key; Type: CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY master.category_group
    ADD CONSTRAINT category_group_cagro_name_key UNIQUE (cagro_name);


--
-- Name: category_group category_group_pkey; Type: CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY master.category_group
    ADD CONSTRAINT category_group_pkey PRIMARY KEY (cagro_id);


--
-- Name: country country_country_name_key; Type: CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY master.country
    ADD CONSTRAINT country_country_name_key UNIQUE (country_name);


--
-- Name: country country_pkey; Type: CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY master.country
    ADD CONSTRAINT country_pkey PRIMARY KEY (country_id);


--
-- Name: policy_category_group policy_category_group_pkey; Type: CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY master.policy_category_group
    ADD CONSTRAINT policy_category_group_pkey PRIMARY KEY (poca_poli_id, poca_cagro_id);


--
-- Name: policy policy_pkey; Type: CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY master.policy
    ADD CONSTRAINT policy_pkey PRIMARY KEY (poli_id);


--
-- Name: provinces provinces_pkey; Type: CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY master.provinces
    ADD CONSTRAINT provinces_pkey PRIMARY KEY (prov_id);


--
-- Name: regions regions_pkey; Type: CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY master.regions
    ADD CONSTRAINT regions_pkey PRIMARY KEY (region_code);


--
-- Name: regions regions_region_name_key; Type: CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY master.regions
    ADD CONSTRAINT regions_region_name_key UNIQUE (region_name);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: users; Owner: postgres
--

ALTER TABLE ONLY users.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: users users_user_phone_number_key; Type: CONSTRAINT; Schema: users; Owner: postgres
--

ALTER TABLE ONLY users.users
    ADD CONSTRAINT users_user_phone_number_key UNIQUE (user_phone_number);


--
-- Name: hotel_reviews update_hotel_rating_star_trigger; Type: TRIGGER; Schema: hotel; Owner: postgres
--

CREATE TRIGGER update_hotel_rating_star_trigger AFTER INSERT OR UPDATE ON hotel.hotel_reviews FOR EACH ROW EXECUTE FUNCTION public.update_hotel_rating_star();


--
-- Name: facilities facilities_faci_cagro_id_fkey; Type: FK CONSTRAINT; Schema: hotel; Owner: postgres
--

ALTER TABLE ONLY hotel.facilities
    ADD CONSTRAINT facilities_faci_cagro_id_fkey FOREIGN KEY (faci_cagro_id) REFERENCES master.category_group(cagro_id);


--
-- Name: facilities facilities_facihotelid_fkey; Type: FK CONSTRAINT; Schema: hotel; Owner: postgres
--

ALTER TABLE ONLY hotel.facilities
    ADD CONSTRAINT facilities_facihotelid_fkey FOREIGN KEY (faci_hotel_id) REFERENCES hotel.hotels(hotel_id);


--
-- Name: facility_photos facility_photos_fapho_faci_id_fkey; Type: FK CONSTRAINT; Schema: hotel; Owner: postgres
--

ALTER TABLE ONLY hotel.facility_photos
    ADD CONSTRAINT facility_photos_fapho_faci_id_fkey FOREIGN KEY (fapho_faci_id) REFERENCES hotel.facilities(faci_id);


--
-- Name: facility_price_history facility_price_history_faph_faci_id_fkey; Type: FK CONSTRAINT; Schema: hotel; Owner: postgres
--

ALTER TABLE ONLY hotel.facility_price_history
    ADD CONSTRAINT facility_price_history_faph_faci_id_fkey FOREIGN KEY (faph_faci_id) REFERENCES hotel.facilities(faci_id);


--
-- Name: facility_price_history facility_price_history_fapri_user_id_fkey; Type: FK CONSTRAINT; Schema: hotel; Owner: postgres
--

ALTER TABLE ONLY hotel.facility_price_history
    ADD CONSTRAINT facility_price_history_fapri_user_id_fkey FOREIGN KEY (faph_user_id) REFERENCES users.users(user_id);


--
-- Name: hotels fk_hotel_addr_id; Type: FK CONSTRAINT; Schema: hotel; Owner: postgres
--

ALTER TABLE ONLY hotel.hotels
    ADD CONSTRAINT fk_hotel_addr_id FOREIGN KEY (hotel_addr_id) REFERENCES master.address(addr_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: hotel_reviews hotel_reviews_hore_user_id_fkey; Type: FK CONSTRAINT; Schema: hotel; Owner: postgres
--

ALTER TABLE ONLY hotel.hotel_reviews
    ADD CONSTRAINT hotel_reviews_hore_user_id_fkey FOREIGN KEY (hore_user_id) REFERENCES users.users(user_id);


--
-- Name: hotel_reviews hotel_reviews_horehotelid_fkey; Type: FK CONSTRAINT; Schema: hotel; Owner: postgres
--

ALTER TABLE ONLY hotel.hotel_reviews
    ADD CONSTRAINT hotel_reviews_horehotelid_fkey FOREIGN KEY (hore_hotel_id) REFERENCES hotel.hotels(hotel_id);


--
-- Name: address address_addr_prov_id_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY master.address
    ADD CONSTRAINT address_addr_prov_id_fkey FOREIGN KEY (addr_prov_id) REFERENCES master.provinces(prov_id);


--
-- Name: country country_country_region_id_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY master.country
    ADD CONSTRAINT country_country_region_id_fkey FOREIGN KEY (country_region_id) REFERENCES master.regions(region_code);


--
-- Name: policy_category_group policy_category_group_poca_cagro_id_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY master.policy_category_group
    ADD CONSTRAINT policy_category_group_poca_cagro_id_fkey FOREIGN KEY (poca_cagro_id) REFERENCES master.category_group(cagro_id);


--
-- Name: policy_category_group policy_category_group_poca_poli_id_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY master.policy_category_group
    ADD CONSTRAINT policy_category_group_poca_poli_id_fkey FOREIGN KEY (poca_poli_id) REFERENCES master.policy(poli_id);


--
-- Name: provinces provinces_prov_country_id_fkey; Type: FK CONSTRAINT; Schema: master; Owner: postgres
--

ALTER TABLE ONLY master.provinces
    ADD CONSTRAINT provinces_prov_country_id_fkey FOREIGN KEY (prov_country_id) REFERENCES master.country(country_id);


--
-- PostgreSQL database dump complete
--

