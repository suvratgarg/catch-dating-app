import {cleanup, fireEvent, render, screen, within} from "@testing-library/react";
import {MemoryRouter} from "react-router";
import {afterEach, expect, it, vi} from "vitest";
import {OrganizerSearchPage} from "./OrganizerSearchPage";
import {hostListings} from "./data";
import {publicEventListingsContext} from "./usePublicEventListingsController";
vi.mock("../../analytics",()=>({trackMarketingEvent:vi.fn()}));
vi.mock("./analytics",()=>({trackOrganizerSearchAppearance:vi.fn()}));
afterEach(cleanup);
const listings = [{...hostListings[0],id:"test-club",name:"Sunday Run Club",city:"Mumbai",formats:["Social runs"]}];
it("shares consumer navigation and preserves profile, Host and claim destinations",()=>{
 render(<MemoryRouter><OrganizerSearchPage listings={listings}/></MemoryRouter>);
 expect(within(screen.getByRole("navigation",{name:"Primary"})).getAllByRole("link").map(link=>link.getAttribute("href"))).toEqual(["/explore/","/organizers/","/host/"]);
 expect(screen.getByRole("heading",{name:"Find your community."})).toBeTruthy();
 expect(screen.getByRole("link",{name:/Sunday Run Club/}).getAttribute("href")).toBe(listings[0].path);
 expect(screen.getByRole("link",{name:"Claim your profile"}).getAttribute("href")).toBe("/claim/");
 expect(screen.getByRole("link",{name:"Explore Catch Host"}).getAttribute("href")).toBe("/host/");
});
it("preserves spaces while typing multiword searches and recovers from an empty city",()=>{
 render(<MemoryRouter><OrganizerSearchPage listings={listings}/></MemoryRouter>);
 const input=screen.getByRole("textbox",{name:"Search organisers"});
 fireEvent.change(input,{target:{value:"Sunday "}});
 expect((input as HTMLInputElement).value).toBe("Sunday ");
 fireEvent.change(input,{target:{value:"Sunday Run"}});
 expect(screen.getByRole("heading",{name:"Sunday Run Club"})).toBeTruthy();
 fireEvent.change(screen.getByRole("combobox",{name:"City"}),{target:{value:"Indore"}});
 expect(screen.getByRole("heading",{name:"No organisers match these filters."})).toBeTruthy();
 fireEvent.click(screen.getByRole("button",{name:"See all organisers"}));
 expect(screen.getByRole("heading",{name:"Sunday Run Club"})).toBeTruthy();
});
it("withholds stale profile cards during a catalogue failure",()=>{
 render(<MemoryRouter><publicEventListingsContext.Provider value={{listings,phase:"unavailable"}}><OrganizerSearchPage/></publicEventListingsContext.Provider></MemoryRouter>);
 expect(screen.getByRole("heading",{name:"We couldn’t load organisers right now."})).toBeTruthy();
 expect(screen.queryByRole("heading",{name:"Sunday Run Club"})).toBeNull();
 expect(screen.getByRole("button",{name:"Try again"})).toBeTruthy();
});
